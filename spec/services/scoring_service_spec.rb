# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScoringService do
  describe ".score" do
    context "with no location" do
      it "doesn't add a score" do
        tracking_event = FactoryBot.create(:tracking_event, location: nil)

        expect { described_class.score(tracking_event:) }.to_not change(Score, :count)
      end
    end

    context "with a registration location" do
      it "doesn't add a score" do
        location = FactoryBot.create(:location, :registration)
        tracking_event = FactoryBot.create(:tracking_event, location:)
        expect(tracking_event.location.registration).to be_truthy

        expect { described_class.score(tracking_event:) }.to_not change(Score, :count)
      end
    end

    context "with a single event" do
      it "creates a single score" do
        tracking_event = FactoryBot.create(:tracking_event)

        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.last
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: tracking_event.rfid_tag_id,
          tracking_event_id: tracking_event.id
        )

        score = Score.where(rfid_tag_id: tracking_event.rfid_tag.id).sum(:score)
        expect(score).to eq(10_000)
      end
    end

    context "with a display location" do
      it "creates a single score" do
        tracking_event = FactoryBot.create(:tracking_event, location: FactoryBot.create(:location, :display))

        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.last
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: tracking_event.rfid_tag_id,
          tracking_event_id: tracking_event.id
        )

        score = Score.where(rfid_tag_id: tracking_event.rfid_tag.id).sum(:score)
        expect(score).to eq(10_000)
      end
    end

    context "for a test event" do
      it "creates a zero value single score" do
        tracking_event = FactoryBot.create(:tracking_event, location: FactoryBot.create(:location, :test_event))
        expect(tracking_event.location.event.test_event?).to eq(true)

        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.last
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 0,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: tracking_event.rfid_tag_id,
          tracking_event_id: tracking_event.id
        )

        score = Score.where(rfid_tag_id: tracking_event.rfid_tag.id).sum(:score)
        expect(score).to eq(0)
      end
    end

    context "with two events for same tag at different locations" do
      it "returns three scores" do
        event = FactoryBot.create(:event)
        locations = FactoryBot.create_list(:location, 2, event:)
        rfid_tag = FactoryBot.create(:rfid_tag)
        events = locations.collect do |location|
          FactoryBot.create(:tracking_event, location:, rfid_tag:)
        end

        tracking_event = events[0]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.last
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: rfid_tag.id,
          tracking_event_id: tracking_event.id
        )

        tracking_event = events[1]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(2)

        scores = Score.order(created_at: :asc).last(2)
        score = scores[0]
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: tracking_event.rfid_tag_id,
          tracking_event_id: tracking_event.id
        )

        score = scores[1]
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-prev-scan-bonus-1",
          score: 1_000,
          score_type: "multi_scan_bonus",
          source: "Bonus: 1000 * 1 previous scans",
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: tracking_event.rfid_tag_id,
          tracking_event_id: tracking_event.id
        )

        score = Score.where(rfid_tag_id: rfid_tag.id).sum(:score)
        expect(score).to eq(10_000 + 10_000 + (1 * 1_000))
      end
    end

    context "with two events for same tag at same location" do
      it "returns three scores" do
        event = FactoryBot.create(:event)
        location = FactoryBot.create(:location, event:)
        rfid_tag = FactoryBot.create(:rfid_tag)
        events = FactoryBot.create_list(:tracking_event, 2, location:, rfid_tag:)

        tracking_event = events[0]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.last
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: rfid_tag.id,
          tracking_event_id: tracking_event.id
        )

        tracking_event = events[1]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event:)
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 100,
          score_type: "scan_again",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: rfid_tag.id,
          tracking_event_id: tracking_event.id
        )
      end
    end

    context "with two events for same tag at same location for test event" do
      it "returns two scores that are both worth zero" do
        event = FactoryBot.create(:event, :test_event)
        location = FactoryBot.create(:location, event:)
        rfid_tag = FactoryBot.create(:rfid_tag)
        events = FactoryBot.create_list(:tracking_event, 2, location:, rfid_tag:)

        tracking_event = events[0]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.last
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 0,
          score_type: "scan"
        )

        tracking_event = events[1]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event:)
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 0,
          score_type: "scan_again"
        )

        score = Score.where(rfid_tag_id: rfid_tag.id).sum(:score)
        expect(score).to eq(0)
      end
    end

    context "with three events for same tag at same location" do
      it "returns three scores" do
        event = FactoryBot.create(:event)
        location = FactoryBot.create(:location, event:)
        rfid_tag = FactoryBot.create(:rfid_tag)
        events = FactoryBot.create_list(:tracking_event, 3, location:, rfid_tag:)

        tracking_event = events[0]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event:)
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: rfid_tag.id,
          tracking_event_id: tracking_event.id
        )

        tracking_event = events[1]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event:)
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 100,
          score_type: "scan_again",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: rfid_tag.id,
          tracking_event_id: tracking_event.id
        )

        tracking_event = events[2]
        expect { described_class.score(tracking_event:) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event:)
        expect(score).to have_attributes(
          id: "#{tracking_event.id}-score",
          score: 100,
          score_type: "scan_again",
          source: /Scan at #{tracking_event.location.name} on .*/,
          event_id: tracking_event.location.event_id,
          location_id: tracking_event.location_id,
          rfid_tag_id: rfid_tag.id,
          tracking_event_id: tracking_event.id
        )
      end
    end

    context "with three events for same tag at different locations" do
      it "returns five scores" do
        event = FactoryBot.create(:event)
        locations = FactoryBot.create_list(:location, 3, event:)
        rfid_tag = FactoryBot.create(:rfid_tag)
        events = locations.collect do |location|
          FactoryBot.create(:tracking_event, location:, rfid_tag:)
        end

        events.each_with_index do |tracking_event, index|
          expect { described_class.score(tracking_event:) }.to change(Score, :count).by(index.zero? ? 1 : 2)
        end

        score = Score.where(rfid_tag_id: rfid_tag.id).sum(:score)
        expect(score).to eq(10_000 +
                            10_000 + (1 * 1_000) +
                            10_000 + (2 * 1_000))
      end
    end

    context "with five events for same tag at different locations" do
      it "returns five scores" do
        event = FactoryBot.create(:event)
        locations = FactoryBot.create_list(:location, 5, event:)
        rfid_tag = FactoryBot.create(:rfid_tag)
        events = locations.collect do |location|
          FactoryBot.create(:tracking_event, location:, rfid_tag:)
        end

        events.each_with_index do |tracking_event, index|
          expect { described_class.score(tracking_event:) }.to change(Score, :count).by(index.zero? ? 1 : 2)
        end

        score = Score.where(rfid_tag_id: rfid_tag.id).sum(:score)
        expect(score).to eq(10_000 +
                           10_000 + (1 * 1_000) +
                           10_000 + (2 * 1_000) +
                           10_000 + (3 * 1_000) +
                           10_000 + (4 * 1_000))
      end
    end

    context "with a single tag and 2 events" do
      it "creates a single score" do
        rfid_tag = FactoryBot.create(:rfid_tag)
        event1 = FactoryBot.create(:event, date: 2.weeks.ago)
        event2 = FactoryBot.create(:event, date: 1.week.ago)
        location1 =  FactoryBot.create(:location, event: event1)
        location2 =  FactoryBot.create(:location, event: event2)
        tracking_event1 = FactoryBot.create(:tracking_event, location: location1, rfid_tag:)
        tracking_event2 = FactoryBot.create(:tracking_event, location: location2, rfid_tag:)

        expect { described_class.score(tracking_event: tracking_event1) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event_id: tracking_event1.id)
        expect(score).to have_attributes(
          id: "#{tracking_event1.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event1.location.name} on .*/,
          event_id: tracking_event1.location.event_id,
          location_id: tracking_event1.location_id,
          rfid_tag_id: tracking_event1.rfid_tag_id,
          tracking_event_id: tracking_event1.id
        )

        expect { described_class.score(tracking_event: tracking_event2) }.to change(Score, :count).by(2)

        scores = Score.where(tracking_event_id: tracking_event2.id).order(created_at: :asc).last(2)

        score = scores[0]
        expect(score).to have_attributes(
          id: "#{tracking_event2.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event2.location.name} on .*/,
          event_id: tracking_event2.location.event_id,
          location_id: tracking_event2.location_id,
          rfid_tag_id: tracking_event2.rfid_tag_id,
          tracking_event_id: tracking_event2.id
        )

        score = scores[1]
        expect(score).to have_attributes(
          id: "#{tracking_event2.id}-multi-event-scan",
          score: 25_000,
          score_type: "multi_event_bonus",
          source: "Bonus: multiple events",
          event_id: tracking_event2.location.event_id,
          location_id: tracking_event2.location_id,
          rfid_tag_id: tracking_event2.rfid_tag_id,
          tracking_event_id: tracking_event2.id
        )

        score = Score.where(rfid_tag_id: rfid_tag.id).sum(:score)
        expect(score).to eq(45_000)
      end
    end

    context "with a single user, 2 tags across 2 events" do
      it "creates a single score" do
        user = FactoryBot.create(:user)
        rfid_tag1 = FactoryBot.create(:rfid_tag, user:)
        rfid_tag2 = FactoryBot.create(:rfid_tag, user:)
        event1 = FactoryBot.create(:event, date: 2.weeks.ago)
        event2 = FactoryBot.create(:event, date: 1.week.ago)
        location1 =  FactoryBot.create(:location, event: event1)
        location2 =  FactoryBot.create(:location, event: event2)
        tracking_event1 = FactoryBot.create(:tracking_event, location: location1, rfid_tag: rfid_tag1)
        tracking_event2 = FactoryBot.create(:tracking_event, location: location2, rfid_tag: rfid_tag2)

        expect { described_class.score(tracking_event: tracking_event1) }.to change(Score, :count).by(1)

        score = Score.find_by(tracking_event_id: tracking_event1.id)
        expect(score).to have_attributes(
          id: "#{tracking_event1.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event1.location.name} on .*/,
          event_id: tracking_event1.location.event_id,
          location_id: tracking_event1.location_id,
          rfid_tag_id: tracking_event1.rfid_tag_id,
          tracking_event_id: tracking_event1.id
        )

        expect { described_class.score(tracking_event: tracking_event2) }.to change(Score, :count).by(2)

        scores = Score.where(tracking_event_id: tracking_event2.id).order(created_at: :asc).last(2)

        score = scores[0]
        expect(score).to have_attributes(
          id: "#{tracking_event2.id}-score",
          score: 10_000,
          score_type: "scan",
          source: /Scan at #{tracking_event2.location.name} on .*/,
          event_id: tracking_event2.location.event_id,
          location_id: tracking_event2.location_id,
          rfid_tag_id: tracking_event2.rfid_tag_id,
          tracking_event_id: tracking_event2.id
        )

        score = scores[1]
        expect(score).to have_attributes(
          id: "#{tracking_event2.id}-multi-event-scan",
          score: 25_000,
          score_type: "multi_event_bonus",
          source: "Bonus: multiple events",
          event_id: tracking_event2.location.event_id,
          location_id: tracking_event2.location_id,
          rfid_tag_id: tracking_event2.rfid_tag_id,
          tracking_event_id: tracking_event2.id
        )

        score = Score.where(rfid_tag_id: [rfid_tag1.id, rfid_tag2.id]).sum(:score)
        expect(score).to eq(45_000)
      end
    end
  end
end
