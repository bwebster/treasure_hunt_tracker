# frozen_string_literal: true

module ApplicationHelper
  def sortable(column, title: nil, default: false)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    icon = if column == params[:sort] || default
             params[:direction] == "asc" ? '<i class="bi bi-caret-up-fill"></i>' : '<i class="bi bi-caret-down-fill"></i>'
           else
             ""
           end
    link_to "#{title}#{icon}".html_safe, { sort: column, direction: direction }, class: "text-decoration-none"
  end

  def human_time(time)
    time.in_time_zone("America/Chicago").strftime("%B %d %l:%M:%S%P")
  end
end
