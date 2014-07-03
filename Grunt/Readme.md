Hi, guys

*I develop a new grunt file to help you save your time
*If your function is not related to backend server, such as java source code
*Then, it may be help

============
Your memory was eaten too much by the eclipse?
You are still try to refresh the page by damaging your F5 key?

You need to try a lighter and easier one:

I put it in the attachment, when you are using this

1. Modify the target page in line 24 to your page, for example, my page is 'ctm-jr'
Modify the index page in line 25, ex. my page is 'create-worksapce.html'

2. cd into the hue-mock\company-hue-mock-front, and type:
`npm install grunt-contrib-connect grunt-contrib-livereload grunt-open connect-livereload`

3.try this out:
`grunt --gruntfile GruntfileXu.js server`

(it will automatically open the page, 
and then, try to modify your source code, save it and see what will be happen)

4. Close your eclipse and time to use a lighter editor, such as sublime text

5. Enjoy it~ Any problem, come to me
