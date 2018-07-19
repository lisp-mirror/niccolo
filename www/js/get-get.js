// got from http://stackoverflow.com/a/901144
// author jolly.exe https://stackoverflow.com/users/1045296/jolly-exe
// © jolly.exe released under creative commons
//Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
//https://creativecommons.org/licenses/by-sa/3.0/

function urlize (s) {
    if (s) {
        return s;
    } else {
        return window.location.href;
    }
}


function getParameterExists (url) {
    url = urlize(url);
    return url.match("\\?[^=]+=");
}

function getFragment (url) {
    url = urlize(url);
    return url.match("#.+$");
}


function getParameterByName(name, url) {
    url = urlize(url);
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
