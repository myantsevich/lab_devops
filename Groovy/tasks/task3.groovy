static boolean isSublist(Object list, Object sublist){
    return sublist.every {it in list}
}
return this