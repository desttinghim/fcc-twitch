import js.Browser;

typedef AjaxRequest = {
    var url:String;
    var options:Map<String, String>;
}

class Web {
    public static function getEl(el:String) {
        return Browser.document.getElementById(el);
    }

    public static function ajax(request:AjaxRequest) {
        var script = Browser.document.createScriptElement();
        script.src = request.url + "?";
        var first = true;
        for(key in request.options.keys()) {
            if (first) first = false;
            else script.src += "&";
            script.src += '${key}=${request.options[key]}';
        }
        Browser.document.head.appendChild(script);
    }
}
