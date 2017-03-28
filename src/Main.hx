import mithril.M;

class Main {
    static function main() {M.mount(js.Browser.document.body, new Twitch());}
}

class Twitch implements Mithril {
    var loaded : Bool;
    var data : Dynamic;
    public function new() {
        loaded = false;
        // data = Json.parse(haxe.Resource.getString("twitch"));
    }
    public function view() [
        m('.error', 'nothing found'),
    ];
    function getData() {
        return ;
    }
}
