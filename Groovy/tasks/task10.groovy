def static urlText(URL){
    def url = "curl -s " + URL;
    return url.execute().text.trim()
}
return this