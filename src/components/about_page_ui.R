about_page_ui <- fluidPage(fluidRow(column(8,offset=2,style = "width:80%; align:center;",
                                                              includeMarkdown("www/mod2.md"),
                                                              h3("How-To:"),
                                                              br(),
                                                              h4(strong("- Uploading files")),
                                                              br(),
                                                              img(src="upload.gif", width="80%" , align= "center"),
                                                              br(),
                                                              br(),
                                                              br(), 
                                                              h4(strong("- Selecting Metrics")),
                                                              br(),
                                                              img(src="metrics.gif", width="80%" , align= "center"))))

module2css <- '#Logo{ width:200%;
                        font-size:30px;
                        display:table-cell;
                        vertical-align:middle;}
               .navbar > .container-fluid {
               padding-left:5%;
                  padding-right:5%;
                  box-shadow: 0 6px 2px -2px rgba(0,0,0,.5);
                  background-color:#1d1d1f;}
              .navbar .navbar-nav {float: right}
              .navbar-nav > li > a > .fa { padding-right:30px }
              .navbar-nav > li > a > b { margin-left:10px }
              .navbar-nav > li > a, .navbar-brand {
                font-size: 1.5rem;
                letter-spacing: 1px;
                margin:0;
                padding-top:auto;
                padding-bottom:1%;
                align-items: center;
                display: flex;
                height: 10vh;
              .navbar-default .navbar-nav > a > .active:after {
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                }
              .navbar {min-height:250px !important;}
              .modal-body{min-height:50vh !important; align:center}
              .shiny-modal modal-content, modal-lg {width: 80vw;}'