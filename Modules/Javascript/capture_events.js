window.addEventListener("message", function (event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow)
   {
    MyApp.blob = JSON.parse(event.data); 
    console.log(MyApp.blob);
  }
});