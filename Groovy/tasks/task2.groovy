static def mulEvenOdd(list) {
    def out = []
    list.each { i ->
        if (i % 2 != 0) {
            out.add (i*3)
        } else {
            out.add (i*2)
        }
    }
    return out
}
return this
