context("CalcDARLEQ")

test_that("CalcDARLEQ returns correct error measures", {
   # skip_on_cran()
    expect_silent(CalcDARLEQ(demoDiatomRiverData, metric = "rivers", version = "latest"))

    bad_data <- data.frame(sampleID =c("1","2","3"),
                                date = c("01/01/2002","01/01/2002","01/01/2002"))
    expect_error(CalcDARLEQ(bad_data, metric = "rivers", version = "latest"),
                 "It seems the input data.frame does not have the required columns")
    expect_error(CalcDARLEQ(metric = "rivers", version = "latest"),
                 "No dataframe has been specified as 'data'")


})

test_that("CalcDARLEQ returns same results as DARLEQ2 tool outputs", {

    # load example data
    riverAquaMetrics  <-  read.csv(system.file("extdata","diatomRivers2012-aquametrics-format.csv",
                                   package = "aquaMetrics"))

    lakesAquaMetrics  <-  read.csv(system.file("extdata","diatomLakes2012-aquametrics-format.csv",
                                               package = "aquaMetrics"))

    # load matching outputs from DARLEQ2 - 'here's one I prepared earlier...'
    riverDARLEQRResults  <-  read.csv(system.file("extdata","ResultsDARLEQRiver2012-tdi4.csv",
                                     package = "aquaMetrics"))

    lakesDARLEQRResults  <-  read.csv(system.file("extdata","ResultsDARLEQLakes2012-ltdi2.csv",
                                                  package = "aquaMetrics"))

    # run example data through CalcDARLEQ function
    riverAquaMetricsResults  <-  CalcDARLEQ(riverAquaMetrics, metric="rivers")
    riverAquaMetricsResults  <- data.frame(riverAquaMetricsResults[1])

    lakeAquaMetricsResults  <-  CalcDARLEQ( lakesAquaMetrics, metric="lakes")
    lakeAquaMetricsResults  <- data.frame( lakeAquaMetricsResults[1])

    # need to round result like Excel
    round_excel = function(x, n) {
      posneg = sign(x)
      z = abs(x)*10^n
      z = z + 0.5
      z = trunc(z)
      z = z/10^n
      z*posneg
    }

    # hack to get rid of decimal place issues:
    # '...since e.g. 0.15 is not represented exactly, the rounding rule applies to the
    # represented number and not to the printed number, and so round(0.15, 1) could
    # be either 0.1 or 0.2).'
    riverAquaMetricsResults$rivers.oTDI4 <- as.character(riverAquaMetricsResults$rivers.oTDI4)
    riverAquaMetricsResults$rivers.oTDI4 <- as.numeric(riverAquaMetricsResults$rivers.oTDI4)

    # check CalcDARLEQ outputs match DARLEQ2 tool outputs
    expect_equal(round_excel(riverAquaMetricsResults$rivers.oTDI4,2), round_excel(riverDARLEQRResults$TDI4,2))
    expect_equal(round_excel(riverAquaMetricsResults$rivers.EQR.TDI4,2), round_excel(riverDARLEQRResults$EQR.TDI4,2))


    expect_equal(round_excel(lakeAquaMetricsResults$lakes.oLTDI2,2), round_excel(lakesDARLEQRResults$LTDI2,2))
    expect_equal(round_excel(lakeAquaMetricsResults$lakes.EQR.LTDI2,2), round_excel(lakesDARLEQRResults$EQR.LTDI2,2))


})


