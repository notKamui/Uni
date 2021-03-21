import { Injectable } from '@angular/core';
import { Todo } from 'src/model/todo';

import { Observable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { TodoResponse } from 'src/model/todoresponse';
import { UpdateTodo } from 'src/model/updatetodo';
import { CreateTodo } from 'src/model/createtodo';

@Injectable({
  providedIn: 'root'
})
export class TodoService {
  constructor(private httpClient: HttpClient) {}

  getTodos(): Observable<Todo[]> {
    return this.httpClient.get<TodoResponse>('https://europe-west1-cours-angular-263913.cloudfunctions.net/todoapp/todo')
      .pipe(
        map(response => response.todos)
      );
  }

  createTodo(label: string): Observable<boolean> {
    return this.httpClient.post<CreateTodo>(
      'https://europe-west1-cours-angular-263913.cloudfunctions.net/todoapp/todo',
      { label }
    ).pipe(
        map(_ => true),
        catchError(_ => of(false))
    );
  }

  updateTodo(todo: Todo): Observable<boolean> {
    return this.httpClient.put<UpdateTodo>(
      'https://europe-west1-cours-angular-263913.cloudfunctions.net/todoapp/todo/' + todo.id,
      { label: todo.label, done: todo.done }
    ).pipe(
      map(_ => true),
      catchError(_ => of(false))
    );
  }

  deleteTodo(todo: Todo): Observable<boolean> {
    return this.httpClient.delete<boolean>(
      'https://europe-west1-cours-angular-263913.cloudfunctions.net/todoapp/todo/' + todo.id
    ).pipe(
      map(_ => true),
      catchError(_ => of(false))
    );
  }
}