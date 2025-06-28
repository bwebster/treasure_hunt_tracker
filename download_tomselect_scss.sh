#!/bin/bash

# Set destination directory
DEST="app/assets/stylesheets/vendor/tom-select/plugins"
REPO="https://raw.githubusercontent.com/orchidjs/tom-select/master/src/plugins"

# Create base directory
mkdir -p "$DEST"

# List of all plugins (from TomSelect source as of v2.3.1)
plugins=(
  auto_position
  caret_position
  checkbox_options
  clear_button
  drag_drop
  dropdown_header
  dropdown_input
  input_autogrow
  no_active_items
  no_backspace_delete
  optgroup_columns
  remove_button
  virtual_scroll
)

# Download each plugin's SCSS
for plugin in "${plugins[@]}"; do
  mkdir -p "$DEST/$plugin"
  curl -sSfL "$REPO/$plugin/plugin.scss" -o "$DEST/$plugin/plugin.scss" && \
    echo "✅ Downloaded $plugin/plugin.scss"
done
