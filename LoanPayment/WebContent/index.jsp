<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Loan calculator</title>
<script type="text/javascript" src="script/jquery-2.1.3.min.js" > </script>
<script type="text/javascript" src="script/jquery-ui.js" > </script>
<script type="text/javascript" src="script/jquery.mobile-1.4.5.min.js" > </script>

<link rel="stylesheet" type="text/css" href="style/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="style/jquery-ui.css">
<link rel="stylesheet" type="text/css" href="style/jquery-ui.structure.css">
<link rel="stylesheet" type="text/css" href="style/jquery-ui.theme.css">
<link rel="stylesheet" type="text/css" href="style/jquery.mobile-1.4.5.min.css">

<style>

.styleTable { border-collapse: separate; }
.styleTable TD { font-weight: normal !important; padding: .4em; border-top-width: 0px !important; }
.styleTable TH { text-align: center; padding: .8em .4em; }
.styleTable TD.first, .styleTable TH.first { border-left-width: 0px !important; }

h1 {
	text-align : center;
	font-weight: bolder;
}

table>thead>tr> td{
	font-weight: bolder;
}

#tabSplit{
	text-align: right;
}

#tabSplit .evenRow{
	background-color: #F4F4F8;
}

#tabSplit .oddRow{
	background-color: #EFF1F1;
}

.pageContent {
 	width:70%;
 	right: 0;
    left: 0;
    margin-right: auto;
    margin-left: auto;
}
</style>

<script type="text/javascript">

	    (function ($) {
	        $.fn.styleTable = function (options) {
	            var defaults = {
	                css: 'styleTable'
	            };
	            options = $.extend(defaults, options);

	            return this.each(function () {

	                input = $(this);
	                input.addClass(options.css);

	                input.find("tr").live('mouseover mouseout', function (event) {
	                    if (event.type == 'mouseover') {
	                        $(this).children("td").addClass("ui-state-hover");
	                    } else {
	                        $(this).children("td").removeClass("ui-state-hover");
	                    }
	                });

	                input.find("th").addClass("ui-state-default");
	                input.find("td").addClass("ui-widget-content");

	                input.find("tr").each(function () {
	                    $(this).children("td:not(:first)").addClass("first");
	                    $(this).children("th:not(:first)").addClass("first");
	                });
	            });
	        };
	    })(jQuery);

	   
	$(function() {
    	$( "#txtDate" ).datepicker({
    		changeMonth: true,
            changeYear: true,
            showButtonPanel: true,
            dateFormat: 'mm/yy',
            onClose: function(dateText, inst) { 
                $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 1));
            }
    	});
  	});

		var calculate = function(){
			var tableDiv = $('#divEmi')[0];
			$(tableDiv).empty();
			
			var loan = $('#txtLoan')[0].value;
			var ist = $('#txtInterest')[0].value;
			var emi = $('#txtEmi')[0].value;			
			var dt = $('#txtDate')[0].value;
			
			var dte = dt.split("/")
			
			var tabText = [];
			
			tabText.push("<table id='tabSplit'>");
			tabText.push("<thead><tr>");
			tabText.push("<td>ID</td>");
			tabText.push("<td>Month</td>");
			tabText.push("<td>Year</td>");
			tabText.push("<td>Principal</td>");
			tabText.push("<td>EMI towards Interest</td>");
			tabText.push("<td>EMI towards Principal</td>");
			tabText.push("<td>Part payment if any</td>");
			tabText.push("</tr></thead>");
			tabText.push("</table>");
			
			$(tableDiv).append(tabText.join(' '));
			
			var pri = loan;
			var m = Math.round(dte[0]);
			var y = dte[1];			
			
			var id = 0;
			
			appendRows(id, emi, ist, pri, m, y);
		}
		
		var appendRows = function(id, emi, ist, pri, m, y){
			while(pri > 0){
				++id;
				var curIst = Math.round(pri * ist/100/12);				
				var curPri = emi - curIst;
				
				if (pri < (emi-curIst))
					curPri = pri;
				
				var table = $('#tabSplit')[0];
				
				var row = [];
				
				row.push("<tr id='tr"+ id +"' class='");
				
				if (id %2 ==0 )
					row.push('evenRow');
				else
					row.push('oddRow');
				
				row.push("'>");
				
				row.push("<td>"+ id +"</td>");
				row.push("<td>"+ m +"</td>");
				row.push("<td>"+ y +"</td>");
				row.push("<td>"+ pri +"</td>");
				row.push("<td>"+ curIst +"</td>");
				row.push("<td>"+ curPri+"</td>");
				
				if ((pri - curPri) > 0)
					row.push("<td><input type='text' id='txtPartPayment"+ id +"' style='width:100px'></td>");
				else
					row.push("<td/>");
				row.push("</tr>");
				
				$(table).append(row.join(' '));				
				
				pri -= curPri;
				
				++m;
				
				if (m > 12){
					m = 1;
					++y;
				}
			}
			
			var typingTimer;              
			var doneTypingInterval = 1000;
			
			$("[id^='txtPartPayment']").keyup(function (){
				clearTimeout(typingTimer);
				typingTimer = setTimeout(partPayment, doneTypingInterval, this.id.split("txtPartPayment")[1]);
			})
			
			$("[id^='txtPartPayment']").keydown(function (){
				clearTimeout(typingTimer);
			})
			
			$('#tabSplit').styleTable();
		}
		
		var partPayment = function(id){
			$("#tabSplit").find("tr:gt("+id+")").remove();
			
			var ist = $('#txtInterest')[0].value;
			var emi = $('#txtEmi')[0].value;
			
			var m = parseInt($('#tr'+id+' td:eq(1)').html());
			var y = parseInt($('#tr'+id+' td:eq(2)').html());
			
			var pri = parseInt($('#tr'+id+' td:eq(3)').html());
			var curIst = parseInt($('#tr'+id+' td:eq(4)').html());
			var curPri = parseInt($('#tr'+id+' td:eq(5)').html());
			var part = $('#tr'+id+' td:eq(6) input')[0].value
			
			pri += curIst;
			pri -= curPri;
			pri -= part;
			
			++m;
			
			if (m > 12){
				m = 1;
				++y;
			}
			
			appendRows(id, emi, ist, pri, m, y);
		} 
		
</script>

</head>

<body>
	<div class="pageContent">
	<h1>Loan Calculator</h1>
	<br>
	<br>
	I have a loan of Rs. <input type="text" id="txtLoan" value="200000"> 
	With yearly interest percentage  <input type="text" id="txtInterest" value="13.25">
	Paying EMI Rs. <input type="text" id="txtEmi" value="15000"> 
	From <input type="text" id="txtDate" value="02/2016">
	<input type="button" id="btnCal" onclick="calculate()" value="Calculate">
	<hr>
	<div id="divEmi" align = "center"></div>
	</div>
	<br>
	<br>
	<br>
	<br>
</body>
</html>