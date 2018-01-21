module indigoprint;

import vibe.vibe;

class IndigoPrint {
  private URLRouter owner;
  private string pathPrefix;

  this(URLRouter owner, string prefix) {
    this.owner = owner;
    this.pathPrefix = prefix;
  }
  URLRouter get(Handler)(string url_match, Handler handler) {
    return owner.get(pathPrefix ~ url_match, handler);
  }
  URLRouter get(string url_match, HTTPServerRequestDelegate handler) {
    return owner.get(pathPrefix ~ url_match, handler);
  }

  URLRouter post(Handler)(string url_match, Handler handler) {
    return owner.post(pathPrefix ~ url_match, handler);
  }
  URLRouter post(string url_match, HTTPServerRequestDelegate handler) {
    return owner.post(pathPrefix ~ url_match, handler);
  }

  URLRouter put(Handler)(string url_match, Handler handler) {
    return owner.put(pathPrefix ~ url_match, handler);
  }
  URLRouter put(string url_match, HTTPServerRequestDelegate handler) {
    return owner.put(pathPrefix ~ url_match, handler);
  }

  URLRouter delete_(Handler)(string url_match, Handler handler) {
    return owner.delete_(pathPrefix ~ url_match, handler);
  }
  URLRouter delete_(string url_match, HTTPServerRequestDelegate handler) {
    return owner.delete_(pathPrefix ~ url_match, handler);
  }

  URLRouter patch(Handler)(string url_match, Handler handler) {
    return owner.patch(pathPrefix ~ url_match, handler);
  }
  URLRouter patch(string url_match, HTTPServerRequestDelegate handler) {
    return owner.patch(pathPrefix ~ url_match, handler);
  }

  URLRouter any(Handler)(string url_match, Handler handler) {
    return owner.any(pathPrefix ~ url_match, handler);
  }
  URLRouter any(string url_match, HTTPServerRequestDelegate handler) {
    return owner.any(pathPrefix ~ url_match, handler);
  }

  URLRouter router() {
    return owner;
  }
}
