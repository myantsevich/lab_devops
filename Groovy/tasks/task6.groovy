static def adults(map) {
    def out = [:]
    map.each { name, age ->
        if (age >= 18)
            out.put(name, age)
    }
    return out
    }

return this
