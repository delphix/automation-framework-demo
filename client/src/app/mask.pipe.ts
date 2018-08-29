import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'mask'
})
export class MaskPipe implements PipeTransform {

  transform(value: string, direction: string, limit: number): any {
    if(!value){
      return value;
    }

    var replace = "";
    if (direction == 'front') {
      replace = value.substr(0, limit);
    }
    if (direction == 'back') {
      replace = value.substr(limit * -1);
    }
    
    var mask = "*".repeat(limit);
    return value.replace(replace, mask);
  }

}
