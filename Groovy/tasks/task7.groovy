def encryptThis(str){
    def out = []
    word = str.split()
    .each { word ->
        out.add((int)word[0] + word[-1] + word[2..-2] + word[1])
    }
    return out.join(" ")
}
return this
