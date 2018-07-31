// https://stackoverflow.com/questions/1147359/how-to-decode-html-entities-using-jquery#1395954
// author lucascaro https://stackoverflow.com/users/428486/lucascaro
// © lucascaro released under creative commons
// Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/

function decodeHtmlEntities (encodedString) {
    var textArea = document.createElement('textarea');
    textArea.innerHTML = encodedString;
    return textArea.value;
}
