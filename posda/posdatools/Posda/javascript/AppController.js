function MenuResponseReturned(text, status, xml){
  document.getElementById('menu').innerHTML = text;
}
function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;
  RunMagicScript();
}
function LoginResponseReturned(text, status, xml){
  document.getElementById('login').innerHTML = text;
}
function TitleAndInfoResponseReturned(text, status, xml){
  document.getElementById('title_and_info').innerHTML = text;
}
function UpdateTitleAndInfo(){
  PosdaGetRemoteMethod("TitleAndInfoResponse", "" , 
    TitleAndInfoResponseReturned);
}
function UpdateMenu(){
  PosdaGetRemoteMethod("MenuResponse", "" , MenuResponseReturned);
}
function UpdateContent(){
  PosdaGetRemoteMethod("ContentResponse", "" , ContentResponseReturned);
}
function UpdateLogin(){
  PosdaGetRemoteMethod("LoginResponse", "" , LoginResponseReturned);
}
function RunMagicScript() {
  // Execute any script found in a .magicscript block
  $(".magicscript").each(function(index, element) {
    eval($(element).text());
  });
}
function Update(){ 
  console.log("update called");
  UpdateTitleAndInfo();
  UpdateMenu();
  UpdateContent();
  UpdateLogin();
}

function makeChartFromSimpleData(data, element, key_msg) {
  var full_data = [];

  $.each(data, function(i, v) {
    full_data.push({x: i, y: v});
  });


  var data = [
    { 
      values: full_data,
      key: key_msg
    },
  ];

  makeChart(data, element);

}
function makeChart(testData, element) {


  nv.addGraph(function() {
      var chart = nv.models.lineChart();

      chart.xAxis.axisLabel('Minutes ago')
        .tickFormat(function(d) {
          return 1440 - d;
        });

      chart.yAxis.axisLabel('Count');

      d3.select("#" + element + " svg")
          .datum(testData)
          .call(chart);

      return chart;
  });
}

