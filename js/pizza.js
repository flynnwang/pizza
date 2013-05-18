COLORS = ['#f00', '#ff0', '#0f0', '#0ff', '#00f', '#f0f', '#000', '#fff'];

$(function() {
    $.each(COLORS, function() {
        var color = this;
        $('.tools').append("<a data-color='" + color + "' style='width: 10px; background: " + color + ";'></a> ");
    });

    color = "#0FF";
        size = 2;

    var stage = new Kinetic.Stage({
        container: 'painting',
        width: 1000,
        height: 500
    });

    var layer = new Kinetic.Layer();

    var circle = new Kinetic.Circle({
        x: stage.getWidth() / 2,
        y: stage.getHeight() / 2,
        radius: 230,
        fill: 'white',
        stroke: 'black',
        strokeWidth: 4
    });
    var center = new Kinetic.Circle({
        x: stage.getWidth() / 2,
        y: stage.getHeight() / 2,
        radius: 2,
        fill: 'white',
        stroke: 'black',
        strokeWidth: 5
    });

    layer.add(circle);
    layer.add(center);

    stage.add(layer);
});
