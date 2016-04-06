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

function makeChartFromSimpleData(rec_data, db_data) {
  var full_rec_data = [];
  var full_db_data = [];

  $.each(rec_data, function(i, v) {
    full_rec_data.push({x: i, y: v});
  });

  $.each(db_data, function(i, v) {
    full_db_data.push({x: i, y: v});
  });

  var data = [
    { 
      values: full_rec_data,
      key: 'recieve_backlog'
    },
    { 
      values: full_db_data,
      key: 'db_backlog'
    },
  ];

  makeChart(data);

}
function makeChart(testData) {


  nv.addGraph(function() {
      var chart = nv.models.lineChart();

      chart.xAxis.axisLabel('Minutes ago')
        .tickFormat(function(d) {
          return 1440 - d;
        });

      chart.yAxis.axisLabel('Count');

      d3.select("#chart svg")
          .datum(testData)
          .call(chart);

      return chart;
  });
}

