pell.init({
    element: document.getElementById('editor-body-message'),
    onChange: html => $("#editor-dump").text(html),
    defaultParagraphSeparator: 'div',
    styleWithCSS: false,
    actions: ['bold',
              'italic',
              'underline',
              'strikethrough',
              'heading1',
              'heading2',
              'paragraph',
              'olist',
              'ulist',
              'line'
             ],
    classes: {
        actionbar: 'pell-actionbar',
        button: 'pell-button',
        content: 'pell-content',
        selected: 'pell-button-selected'
    }
})
