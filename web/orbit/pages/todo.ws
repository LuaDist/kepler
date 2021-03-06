#!/usr/bin/env wsapi.cgi

require "orbit"
require "orbit.pages"
require "cosmo"
require "luasql.sqlite3"

local todo = orbit.new()

todo.mapper.conn = luasql.sqlite3():connect(todo.real_path .. "/todo.db")

local todo_list = todo:model("todo_list")

local function item_list()
  return todo_list:find_all{ order = "created_at desc" }
end

local function index(web)
  local list = web:page_inline(todo.items, { items = item_list() })
  return web:page_inline(todo.index, { items = list })
end

todo:dispatch_get(index, "/")

local function add(web)
  local item = todo_list:new()
  item.title = web.input.item or ""
  item:save()
  return web:page_inline(todo.items, { items = item_list() })
end

todo:dispatch_post(add, "/add")

local function remove(web, id)
  local item = todo_list:find(tonumber(id))
  item:delete()
  return web:page_inline(todo.items, { items = item_list() })
end

todo:dispatch_post(remove, "/remove/(%d+)")

local function toggle(web, id)
  local item = todo_list:find(tonumber(id))
  item.done = not item.done
  item:save()
  return "toggle"
end

todo:dispatch_post(toggle, "/toggle/(%d+)")

todo.index = [===[
  <html>
  <head>
  <title>To-do List</title>
  <script type="text/javascript" src="/jquery/jquery-1.2.3.min.js"></script>
  <script>
  function set_callbacks() {
    $(".remove").click(function () {
      $("#items>[item_id=" + $(this).attr("item_id") +"]").slideUp("slow");
    $("#items").load("todo.ws/remove/" + $(this).attr("item_id")", {},
      function () { set_callbacks(); });
    });
    $(".item").click(function () {
      $.post("todo.ws/toggle/" + $(this).attr("item_id"), {});
    });
  }

  $(document).ready(function () {
    $("#add").submit(function () {
      $("#button").attr("disabled", true);
      $("#items").load("todo.ws/add", { item: $("#title").val()  }, 
        function () { $("#title").val(""); set_callbacks(); 
        $("#button").attr("disabled",false); });
      return false;
    });
    set_callbacks();
  });
  </script>
  <style>
  ul { padding-left: 0px; }
  li { list-style-type: none;} 
  .remove { font-size: xx-small; }
  </style>
  </head>
  <body>
  <h1>To-do</h1>
  <ul id="items">
  $items
  </ul>
  <form id = "add" method = "POST" action = "todo.ws">
  <input id = "title" type = "text" name = "item" size = 30 />
  <input id = "button" type = "submit" value = "Add" />
  </form>
  </body>
  </html>
]===]

todo.items = [===[
  $if{$items|1}[==[
  $items[[
  <li item_id="$id"><input class="item" type="checkbox" $if{$done}[=[checked]=] item_id="$id"/> $title
    <a href = "#" class = "remove" item_id = "$id">Remove</a></li>
  ]]
  ]==],[==[Nothing to do!]==]
]===]

return todo
