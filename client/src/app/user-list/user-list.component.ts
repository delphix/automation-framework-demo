import { Component, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { UserService } from '../shared/user/user.service';
import { MatTableDataSource, MatSort } from '@angular/material';

export interface User{
  id: number;
  username: string;
  firstname: string;
  lastname: string;
  createdAt: string;
  updatedAt: string;
}

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  styleUrls: ['./user-list.component.css']
})

export class UserListComponent implements OnInit {

  displayedColumns: string[] = ['username', 'firstname', 'lastname', 'actions'];
  dataSource = new MatTableDataSource([]);
  @ViewChild(MatSort) sort: MatSort;

  constructor(private userService: UserService) { }

  ngOnInit() {
    this.userService.getAll().subscribe(data => {
      var userData: User[] = data.content;
      this.dataSource = new MatTableDataSource(userData);
      this.dataSource.sort = this.sort;
    });
  }

  remove(id) {
    if(confirm(`Are you sure you want to delete this user?`)) {
      this.userService.remove(id).subscribe(result => {
        this.userService.getAll().subscribe(data => {
          var userData: User[] = data.content;
          this.dataSource = new MatTableDataSource(userData);
          this.dataSource.sort = this.sort;
        });
      }, error => console.error(error));
    }
  }

}
