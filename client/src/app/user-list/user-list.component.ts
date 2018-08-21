import { Component, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { UserService } from '../shared/user/user.service';
import { User } from '../shared/user/user.model';
import { MatTableDataSource, MatSort } from '@angular/material';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  styleUrls: ['./user-list.component.css']
})

export class UserListComponent implements OnInit, AfterViewInit {

  @ViewChild(MatSort) sort: MatSort;
  public users: User[];
  dataSource = new MatTableDataSource(this.users);
  displayedColumns = ['username', 'firstname', 'lastname'];

  constructor(private userService: UserService) { }

  ngOnInit() {
    this.userService.getAll().subscribe(data => {
      this.users = data.content;
      this.dataSource = new MatTableDataSource(this.users);
    });
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
  }
}
