import mithril.M;

class Main {
    static function main() {M.mount(js.Browser.document.body, new Twitch());}
}

class Twitch implements Mithril {
    var loaded : Bool;
    var data : Dynamic;
    public function new() {
        loaded = false;
        data = getData();
        M.redraw();
    }
    public function view() [
        m('.error', data),
    ];
    function getData() {
        return haxe.Json.parse(haxe.Resource.getString("twitch"));
    }
}
