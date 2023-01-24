module TravelingSalesmanGUI

using JSON, GLMakie

include("Constants.jl")

export load_input

function load_input(file_name::AbstractString)
    input = JSON.parsefile(file_name)
    cities = input["cities"]

    set_theme!(theme_dark())
    figure = Figure(resolution = (height, width), title = "Traveling Salesman");

    figure[0, 1:2] = Label(figure, "Traveling Salesman", fontsize = 30)

    axis_grid = figure[1, 1] = GridLayout()
    button_grid = figure[2, 1:2] = GridLayout()
    slider_grid = figure[3, 1:2] = GridLayout()
    best_found_grid = figure[1, 2] = GridLayout()

    best_label_grid = best_found_grid[1, 1] = GridLayout()
    best_axis_grid = best_found_grid[1, 2] = GridLayout()



    axis = Axis(axis_grid[1, 1], title = "Traveling Salesman", xlabel = "x", ylabel = "y")
    x = range(-10, stop=10, length = 20)
    y = x.^2
    scatterlines!(axis, x, y; markersize = 15)
    scatter!(axis, x[1], y[1], markersize = 15, color = :red)

    sliders = SliderGrid(slider_grid[1, 1],
        (label = "Step interval", range = 0:1:1000, format = x -> string(x, " ms")),
        (label = "Population size", range = 0:1:100),
        (label = "Crossover chance", range = 0:0.0001:1, format = x -> string(round(100 * x, digits=4), " %")),
        (label = "Mutation chance", range = 0:0.0001:1, format = x -> string(round(100 * x, digits=4), " %"))
    )

    button_labels = ["Play", "Pause", "Clear & Reset", "Step", "Default"]

    buttons = [
        Button(button_grid[1, index], label = label)
        for (index, label) in enumerate(button_labels)
    ]

    step_interval = sliders.sliders[1].value
    population_size = sliders.sliders[2].value
    crossover_chance = sliders.sliders[3].value
    mutation_chance = sliders.sliders[4].value

    label_labels = [
        "Current iteration: ", 
        "Current shortest distance: ", 
        "Current best: ", 
        "Best distance: ",
        "Best: "
    ]

    info_labels = [
        Label(best_label_grid[index, 1], label)
        for (index, label) in enumerate(label_labels)
    ]

    best_axis = Axis(best_axis_grid[1, 1], title = "Shortest distance", xlabel = "x", ylabel = "y")

    x = range(-10, stop=10, length = 20)
    y = abs.(x)
    scatterlines!(best_axis, x, y; markersize = 15)
    scatter!(best_axis, x[1], y[1], markersize = 15, color = :red)

    sc = display(figure);
end

end
