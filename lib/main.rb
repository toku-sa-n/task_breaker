# The format of TODO_FILE
# {content of todo},{0(undone) or 1(done)},{level}
# level: 0 is root. level of subtodos starts from 1.

TODO_FILE = "#{ENV['HOME']}/.todo".freeze
COMPLETED = 1
UNCOMPLETED = 0

def show_help
  #  print <<EOF
  # Usage: todo COMMAND ARGUMENTS
  #   add     TODO:        Add a todo.
  #   check   NUMBER:      Mark a todo as completed.
  #   uncheck NUMBER:      Mark a todo as incompleted.
  #   change  NUMBER TODO: Change a todo.
  #   delete  NUMBER:      Delete a todo.
  #   subtodo NUMBER TODO: Add a subtodo.
  #   show:                Show todos.
  #   help:                Show this message.
  # EOF
end

def add_todo(todo)
  if todo.nil?
    show_help
    return 1
  end

  File.open(TODO_FILE, 'a') do |file|
    file.puts("#{todo},0,0")
  end
end

def change_todo_process(todo_index, process_number)
  # process_number is either 0(undone) or 1(done).

  todo_index_number = todo_index.to_i

  # if todo_index_number is 0, todo_index was an invalid number because to_i converts any non-number to 0.
  if todo_index_number == 0
    show_help
    return 1
  end

  # read all lines, check the specified todo, then join all todos and write it to TODO file.
  todo_lines = File.readlines(TODO_FILE)
  # check or uncheck the specified todo.
  todo_lines[todo_index_number - 1].gsub!(/(\w+),[01],([0-9]+)/) { "#{Regexp.last_match(1)},#{process_number},#{Regexp.last_match(2)}" }
  File.open(TODO_FILE, 'w') do |file|
    file.write(todo_lines.join)
  end
end

def check_todo(todo_index)
  change_todo_process(todo_index, COMPLETED)
end

def uncheck_todo(todo_index)
  change_todo_process(todo_index, UNCOMPLETED)
end

def show_todos
  File.open(TODO_FILE).each_line do |line|
    todo_content, todo_status = line.match(/(.+),([01]),[0-9]+/)[1..2]
    if todo_status.to_i == 0 # if the todo is not completed.
      print "\e[31m#{todo_content}\e[0m\n" # \e[31m colorizes to red. \e[0m will reset color.
    else
      puts "\e[32m#{todo_content}\e[0m" # \e[32m colorizes to green.
    end
  end
end

def main
  case ARGV[0]
  when 'add'
    add_todo(ARGV[1])
  when 'check'
    check_todo(ARGV[1])
  when 'uncheck'
    uncheck_todo(ARGV[1])
  when 'show'
    show_todos
  when 'help'
    show_help
  end
end

main