using Revise
using TravelingSalesmanGUI

test = GUI(Dict())

for i in 1:5
    println(test.sliders)
    testovic = get_slider_value(test, "Step")
    println("New value of Step is $testovic")
#     testik = get_button_value(test, "Play")
#     println("New value of Play is $testik")

#     if testik
#         set_button_value(test, "Play")
#         testik = get_button_value(test, "Play")
#         println("Change value of Play back to default ($testik)")
#     end

    sleep(5)
end