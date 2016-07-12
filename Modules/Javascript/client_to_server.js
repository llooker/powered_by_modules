var MyApp = {};

window.addEventListener("message", function (event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow)
   {
    MyApp.blob = JSON.parse(event.data); 
    console.log(MyApp.blob);
  }
});


// callback handler for form submit
$(function(){
  $("#create_look_explore").submit(function(event){
    event.preventDefault();

    // var action = $(this).attr('action');
    // var method = $(this).attr('method');

    MyApp.event_URL = MyApp.blob.explore.url;

    console.log(MyApp.event_URL);
    var title = $(this).find('#title_of_look').val();

    $.ajax({
		method: "post",
		url: "/create_look",
		data: { title: title, event_URL: MyApp.event_URL }, 
		dataType: 'json', 
 
		success: function(data,status,xhr){
			console.log(data.message);
			alert(data.message);
		},
		error: function(xhr,status,error){
			console.log(xhr);
			alert('Enter a Valid Query and a Unique Title \n' + error);
		}
	});

  });
});
