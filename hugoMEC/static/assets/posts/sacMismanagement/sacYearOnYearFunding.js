// Constant parameters 
// recall that some const vars are available because they are declared in earlier scripts (eg. colors)
const LINE_MARGINS = {top: 50, bottom:25, right: 50, left: 50};

const LINE_WIDTH = 800 - LINE_MARGINS.left - LINE_MARGINS.right;
const LINE_HEIGHT = 350 -  LINE_MARGINS.top -  LINE_MARGINS.bottom;


//chart construction and data read-in
const line_data = d3.csv('assets/posts/sacMismanagement/SACYearOnYearFYChanges.csv').then(
    line_data => {

        // formatting FiscalYear into d3 recognized time format
        line_data = line_data.map(d =>{
            numYear = parseInt(d.FiscalYear);
            newFunding = parseInt(d.Funding);
            timeFormatter = d3.timeParse('%Y');
            newYear = timeFormatter(numYear);
            return {
                FiscalYear: newYear,
                Funding: newFunding
            };
        });

        // theoretical axis setup
        xMinMax = d3.extent(line_data, d => d.FiscalYear);
        yMinMax = d3.extent(line_data, d => d.Funding);

        //x-axis (YEAR)
        const xScale = d3.scaleTime(line_data)
            .domain([xMinMax[0], xMinMax[1]])
            .range([0, LINE_WIDTH]);
        //y-axis (DOLLARS)
        const yScale = d3.scaleLinear(line_data)
            .domain([0, yMinMax[1] ])
            .range([LINE_HEIGHT, LINE_MARGINS.top]);
        
        //creating line chart container and the base line chart svg
        const lineContainer = d3.select('#sacYearOnYearLine')
            .append('svg')
            .classed('container', true)
            .attr('preserveAspectRatio', 'xMidYMid meet')
            .attr('viewBox', '0 0 ' + (LINE_WIDTH + LINE_MARGINS.left + LINE_MARGINS.right) + ' 300');
        const line = lineContainer.append('g');
        
        //creating line path
        const line_path = d3.line()
            .x(d => xScale(d.FiscalYear))
            .y(d => yScale(d.Funding));
       
        //yaleblue = #0a5282
        line.append('path')
            .datum(line_data)
            .attr('fill', 'none')
            .attr('stroke', "#0a5282")
            .attr('stroke-width', 1.5)
            .attr('d', line_path(line_data))
            .attr('transform', `translate(${LINE_MARGINS.left}, 0)`);


        //creating actual axes based on theoretical axes above
        //formatting y-axis labels to dollars
        function formatTick(line_data){
            const s = commaFormat(line_data);
            return this.parentNode.nextSibling ? `\xa0${s}` :`$${s}` 
        }

        const xAxis = d3.axisBottom(xScale);
        const yAxis = g => g
            .call(d3.axisRight(yScale)
                .tickSize(LINE_WIDTH)
                .tickSizeOuter(0)
                .ticks(6)
                .tickFormat(formatTick))
            .call(g => g.select('.domain')
                .attr('opacity', 0))
            .call(g => g.selectAll('.tick:not(:first-of-type) line')
                .attr('stroke-opacity', 0.5)
                .attr('stroke-dasharray', '2,2'))
            .call(g => g.selectAll('.tick text')
                .attr('x', '10px')
                .attr('dy', -6));
        //attaching axes to chart
        line.append('g')
            .attr('transform', `translate(${LINE_MARGINS.left}, ${LINE_HEIGHT})`)
            .call(xAxis);
        line.append('g')
            .attr('transform', `translate(${LINE_MARGINS.left}, 0)`)
            .call(yAxis);

        //line title
        const title = d3.select('#sacYearOnYearLine').append('div');
        function titlePlacement(){
            title
                .classed('chartTitle', true)
                .style('left', function(){
                    yAxisCoords = d3.selectAll('.domain')
                        .filter(function(){
                            return d3.select(this).attr('opacity') == 0;
                        })
                        .node().getBoundingClientRect()
                    return yAxisCoords.x + 'px';
                })
                .text('SAC Funds Appropriated by GUSA FinApp');               
        }
        titlePlacement()
        window.onresize = titlePlacement;
    }

    
);

