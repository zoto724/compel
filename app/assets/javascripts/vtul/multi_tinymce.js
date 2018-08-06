var tinymceDescriptionNumber = 0;
var descriptionDiv = 'div.base-terms > div.composition_description';
var addButton = descriptionDiv + ' button.btn-link.add';
var editors = descriptionDiv + ' ul.listing > li.field-wrapper.input-group';

Blacklight.onLoad(function() {
  $(document).on('click', addButton, function(){
    var $newEditorLi = $(editors).last();
    var $newTextArea = $newEditorLi.find('textarea.composition_description');
    var $fieldControls = $newEditorLi.find('span.input-group-btn.field-controls');
    $newEditorLi.empty();
    $newTextArea.attr('id', 'composition_description_' + tinymceDescriptionNumber++);
    $newEditorLi.append($newTextArea);
    $newEditorLi.append($fieldControls);
    window.tinyMCE.init({
      selector: 'textarea#' + $newTextArea.attr('id'),
      width: 542,
      height: 293,
      init_instance_callback: function (editor) {
        console.log($newEditorLi.find('div.mce-tinymce.mce-container.mce-panel'));
        $newEditorLi.find('div.mce-tinymce.mce-container.mce-panel').show();
      }
    });
  });  

});
