import ballerina/graphql;

# A service representing a network-accessible GraphQL API
service graphql:Service /graphql on new graphql:Listener(7090) {

    # Returns all Todo items with optionally filtered from the done status.
    # + done - Optional filter to list the Todo items by done status.
    # + return - The list of Todo's.
    resource function get allTodos(boolean? done) returns Todo[] {
        lock {
            Todo[] todos;
            if done is boolean {
                todos = from var todo in todoTable
                    where todo.done == done
                    select todo;
            } else {
                todos = from var todo in todoTable
                    select todo;
            }
            return todos.cloneReadOnly();
        }
    }

    # Returns a Todo item from a given Id.
    # + id - Id of the required Todo item.
    # + return - Todo item for the given Id if it exists or else returns null.
    resource function get todo(int id) returns Todo? {
        lock {
            if todoTable[id] is Todo {
                return todoTable[id].cloneReadOnly();
            }
            return;
        }
    }

    # Add a Todo item.
    # + todoInput - User input for the new Todo item.
    # + return - Newly created Todo item.
    remote function createTodo(CreateTodoInput todoInput) returns Todo {
        lock {
            int id = todoTable.length() + 1;
            Todo newTodo = {
                id: id,
                title: todoInput.title,
                done: false
            };
            if (todoInput.description is string) {
                newTodo.description = <string>todoInput.description;
            }
            todoTable.add(newTodo);
            return newTodo.cloneReadOnly();
        }
    }

    # Update the done state of a Todo item.
    # + id - Id of the updating Todo item.
    # + done - Flag indicating the done status.
    # + return - updated Todo item.
    remote function setDone(int id, boolean done) returns Todo? {
        lock {
            Todo? todo = todoTable[id];
            if (todo is ()) {
                return;
            }
            todo.done = done;
            return todo.cloneReadOnly();
        }
    }
}
