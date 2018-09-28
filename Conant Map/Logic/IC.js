function getTable(){
    var content = document.getElementById('frameDetail').contentWindow.document.getElementById('content')

    var parentTable;
    for(i = 0; i < content.children.length; i++){
        if(content.children[i].tagName === 'TABLE'){
            parentTable = content.children[i];
            break
        }
    }
    var table = parentTable.children[0].children[2].children[0].children[0];
    var p = '';
    var p2 = '';
    for(i = 1; i < table.children[0].children.length - 1; i++) {
        var cell = table.children[0].children[i];
        var period = cell.children[0].innerHTML;

        if(cell.children.length === 1){
            var prevCell = table.children[0].children[i-1];
            var sem1 = prevCell.children[1];
            var sem2 = prevCell.children[2];
            p += period + ',' + getInformation(sem1);
            p2 += period + ',' + getInformation(sem2)
        }else if(cell.children.length === 3){
            var sem1 = cell.children[1];
            var sem2 = cell.children[2];
            p += period + ',' + getInformation(sem1);
            p2 += period + ',' + getInformation(sem2)
        }


    }

    return p + 'S2,' + p2

}

function getInformation(sem){
    if(sem.children.length > 0){
        var info = sem.children[0];
        var name = info.children[0].children[1].innerHTML;
        name = name.substring(name.indexOf(' ') + 1);
        var parser = new DOMParser;
        var dom = parser.parseFromString('<!doctype html><body>' + name, 'text/html');
        name = dom.body.textContent;

        var room = info.innerHTML;
        var startIndex = room.indexOf('Rm:');
        var endIndex = startIndex;
        var findingEnd = true;
        while (findingEnd){
            if(room.substring(endIndex, endIndex +1) === '<'){
                findingEnd = false;
            }else{
                endIndex++;
            }
        }
        room = room.substring(startIndex, endIndex);
        room = room.substring(4);

        return name + ',' + room + ','
    }else if(sem.children.length === 0){
        if(sem.innerHTML.indexOf('EMPTY') !== -1){
            return 'EMPTY,None,'
        }
    }
}
