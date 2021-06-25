// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery3
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets

//= require_tree .

(function() {
    $(document).ready(function() {
      var addRow, hideRemoveButton, removeRow;
      addRow = function(ev) {
        var $nearest_row, $new_row, $remove_button;
        ev.preventDefault();
        $nearest_row = $(this).prev();
        $nearest_row.find('.text-array__remove').show();
        $new_row = $nearest_row.clone();
        $new_row.find('input').val("");
        $remove_button = $new_row.find('.text-array__remove');
        $remove_button.click(removeRow);
        return $new_row.insertBefore(this);
      };
      removeRow = function(ev) {
        ev.preventDefault();
        this.parentElement.remove();
        return hideRemoveButton();
      };
      hideRemoveButton = function() {
        return $('.text-array').each(function(i, el) {
          var $rows;
          $rows = $(el).children('.text-array__row');
          if ($rows.length === 1) {
            return $rows.find('.text-array__remove').hide();
          }
        });
      };
      $('.text-array__add').click(addRow);
      $('.text-array__remove').click(removeRow);
      return hideRemoveButton();
    });
  
  }).call(this);
