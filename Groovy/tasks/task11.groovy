def gstring(str, n) {
    switch(n) {
        case 1:
            template = "1(${str}) 2() 3()";
            break;
        case 2:
            template = "1() 2(${str}) 3()";
            break;
        case 3:
             template = "1() 2() 3(${str})";
            break;
        default:
            println("The value is unknown");
            break;
    }
    return template
}
return this

//println(gstring("test", 2))
