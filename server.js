const http = require('http');
const express = require('express');
const router = express.Router();
const multer = require('multer');
const ejs = require('ejs');
const path = require('path');


const storage = multer.diskStorage({
    destination: './public/uploads/',
    filename: function(req, file, cb){
      cb(null,file.fieldname + '-' + (pics.length) /*Date.now()*/ + path.extname(file.originalname));
    }
  });

// Init Upload
const upload = multer({
    storage: storage,
    limits:{fileSize: 1000000},
   // fileFilter: function(req, file, cb){
      //checkFileType(file, cb);
   // }
  }).single('File');

  /*/ Check File Type
function checkFileType(file, cb){
    const filetypes = /jpeg|jpg|png|gif/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);
  
    if(mimetype && extname){
      return cb(null,true);
    } else {
      cb('Error: Images Only!');
    }
  }*/

const app = express();
app.set('view engine', 'ejs');

app.use(express.static('./public'));

app.get('/', (req, res) => res.render('index'));
let pics = [];
app.post('/upload', (req, res) => {
  upload(req, res, (err) => {
    pics.push(req.file);
    console.log(pics.length);
    if(err){
      res.render('index', {
        msg: err
      });
    } else {
      if(req.file == undefined){
        res.render('index', {
          msg: 'Error: No File Selected!'
        });
      } else {
        /*let a = 1;
        for (let i = 0;i < a;i+=1){
          res.render('index2', {
          msg: 'File Uploaded!',
          file: `uploads/${req.file.filename}`
        });*/
        
      /*  pics.push('index2',{
          msg: 'File Uploaded!',
          file: `uploads/${req.file.filename}`
        });
        res.render(`pics`);
        */
    //}
        res.render('index', {
          msg: 'File Uploaded!',
          file: //function(){
           // for (let i = 0;i < pics.length; i++){
              `uploads/${req.file.filename}`
            //}
          //}
          });
        }
    }
    });
}
);
/*const server = http.createServer((request, response) => {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end("Hello World!wwwwwwwwwwwwwwwwwwwwwww");
});*/

const port = process.env.PORT || 1337;
app.listen(port);

console.log("Server running at http://localhost:%d", port);