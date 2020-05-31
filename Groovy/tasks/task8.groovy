import groovy.json.*
def parseAndFilterJson(guys) {
    result = [:]
    JsonSlurper slurper = new JsonSlurper()
    Map i = slurper.parseText(guys)
    i.each {
        name, age ->
            if (age%9==0) {
                result.put(name, age)
            }
    }
    JsonOutput.toJson(result)
}
return this