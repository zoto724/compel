var tinymceDescriptionNumber = 0;
var compositionDiv = 'div.base-terms > div.composition_description';
var performanceDiv = 'div.base-terms > div.performance_description';
var collectionDiv = 'div#base-terms > div.collection_description';
var addSelector = 'button.btn-link.add';
var addButton = compositionDiv + ' ' + addSelector + ', ' + performanceDiv + ' ' + addSelector + ', ' + collectionDiv + ' ' + addSelector;
var editorSelector = 'ul.listing > li.field-wrapper.input-group';
var editors = compositionDiv + ' ' + editorSelector + ', ' + performanceDiv + ' ' + editorSelector + ', ' + collectionDiv + ' ' + editorSelector;

Blacklight.onLoad(function() {
  $(document).on('click', addButton, function(){
    var $newEditorLi = $(editors).last();
    var $newTextArea = $newEditorLi.find('textarea.collection_description, textarea.composition_description, textarea.performance_description');
    var $fieldControls = $newEditorLi.find('span.input-group-btn.field-controls');
    $newEditorLi.empty();
    $newTextArea.attr('id', 'description_' + tinymceDescriptionNumber++);
    $newEditorLi.append($newTextArea);
    $newEditorLi.append($fieldControls);
    window.tinyMCE.init({
      selector: 'textarea#' + $newTextArea.attr('id'),
      width: "100%",
      height: 294,
      init_instance_callback: function (editor) {
        console.log($newEditorLi.find('div.mce-tinymce.mce-container.mce-panel'));
        $newEditorLi.find('div.mce-tinymce.mce-container.mce-panel').show();
      }
    });
  });  

});
