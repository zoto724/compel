var tinymceClass = '.tinymce'
var tinymceDescriptionId = "composition_description_";
var tinymceIFrameId = "_ifr"
var tinymceDescriptionNumber = 0;
var descriptionDiv = 'div.base-terms > div.composition_description';
var addButton = descriptionDiv + ' button.btn-link.add';
var editors = descriptionDiv + ' ul.listing > li.field-wrapper.input-group';

function addMultiTinymce(mutation) {
  for (var i = 0; i < mutation.addedNodes.length; i++) {
    var iframe_node = mutation.addedNodes[i].querySelector('iframe');
    var textarea_node = mutation.addedNodes[i].querySelector('textarea');
    var textarea_id = tinymceDescriptionId + tinymceDescriptionNumber;
    if (iframe_node && textarea_node) {
      tinyMCE.remove("textarea.tinymce");
      textarea_node.setAttribute('id', textarea_id);
      iframe_node.setAttribute('id', textarea_id + tinymceIFrameId);
      tinymceDescriptionNumber++;
      tinyMCE.init({
        selector: 'textarea.tinymce',
        init_instance_callback: function (editor) {
          editor.on('focus', function (e) {
            console.log('Editor got focus!');
          });
          tinymce.on('AddEditor', function (e) {
            console.log('Added editor with id: ' + e.editor.id);
          });
        }
      });
    console.log(textarea_node.id);
    }
  }
}

Blacklight.onLoad(function() {
  $(document).on('click', addButton, function(){
    var $newEditorLi = $(editors).last();
    var $newTextArea = $newEditorLi.find('textarea.composition_description');
    $newEditorLi.empty();
    $newTextArea.attr('id', 'composition_description_' + tinymceDescriptionNumber++);
    $newEditorLi.append($newTextArea);
    window.tinyMCE.init({
      selector: 'textarea#' + $newTextArea.attr('id'),
      width: 542,
      height: 293,
      init_instance_callback: function (editor) {
        console.log($newEditorLi.find('div.mce-tinymce.mce-container.mce-panel'));
        $newEditorLi.find('div.mce-tinymce.mce-container.mce-panel').show();
        tinymce.on('AddEditor', function (e) {
          console.log(e);
          $newEditorLi.find('div.mce-tinymce.mce-container.mce-panel').show();
        });
      }
    });
  });  

/**
  if($(tinymceClass).length) {
    $(tinymceClass).each(function() {
      tinyMCE.init({
        selector: 'textarea.tinymce',
      });
      var tinymceObserver = new MutationObserver(function(mutations){
        mutations.forEach(addMultiTinymce);
      });
      tinymceObserver.observe($(this).closest('div')[0], {subtree: true, childList: true});
    });
  }
**/
});
