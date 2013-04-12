RECIPES_PATH = "./recipes"
LIB_PATH = "./lib"
$LOAD_PATH.unshift(LIB_PATH)

def is_a_recipe?(filename)
  Dir.foreach(RECIPES_PATH) do |item|
    next if item == '.' || item == '..'
    return true if filename == item
  end
  false
end

task :default => :list

desc "Shows all recipes available"
task :list do
  puts "Available recipes:"
  puts "-----------------"

  Dir.foreach(RECIPES_PATH) do |item|
    next if item == '.' || item == '..'
    puts item
  end
end

desc "Compiles a given recipe"
task :compile, :recipe do |t, args|
  recipe = args.recipe
  args.with_defaults(:recipe => "Usage: rake 'compile[<recipe_name>]'")

  if !is_a_recipe?(recipe)
    puts "Incorrect recipe!"
    exit
  end

  path = "#{RECIPES_PATH}/#{recipe}"
  puts "Compiling #{recipe}"
  puts "-------------------"
  load path
end
