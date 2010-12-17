$(document).ready(function(){ 
  sendQuery();
});




function loadImage(){


  $.get(
    'http://localhost:3000/system/images/7a/c4/7ac4f04473164c715bc84be02f6099236f97d472-168.jpeg',
    function(data){
      
      
      // // Render image.
      // var span = document.createElement('span');
      // span.innerHTML = ['<img class="thumb" src="', data,'" title="a title"/>'].join('');
      // document.getElementById('list').insertBefore(span, null);
      
      
       // alert("Data Loaded: " + data);
       
       
       $.ajax({
         url: 'http://localhost:3000/queries.xml',
         type: 'POST',
         contentType:'multipart/form-data',
         data: 'dcs.source=boss-web&query=data&dcs.algorithm=lingo&dcs.output.format=JSON&dcs.clusters.only=true', 
         //dataType: "jsonP",
         success: function(jsonData) {alert('POST alert'); data=jsonData ; },
         error : function(XMLHttpRequest, textStatus, errorThrown) {
                   console.log('An Ajax error was thrown.');
                   console.log(XMLHttpRequest);
                   console.log(textStatus);
                   console.log(errorThrown);
                 }
       });
       
     });
     
     img = new Image(); 
     img.src = "http://localhost:3000/system/images/7a/c4/7ac4f04473164c715bc84be02f6099236f97d472-168.jpeg";
     document.getElementById('list').appendChild( img );
     
     alert(img.data);
     
     
}


function sendQuery(){
  var img = loadImage();
  
  // var reader = new FileReader();
  // 
  // reader.onload = function(e){
  //   var bin = e.target.result
  //   alert(bin);
  //  }
  //  
  //  reader.readAsBinaryString(img); 
    
  // alert(img);
}