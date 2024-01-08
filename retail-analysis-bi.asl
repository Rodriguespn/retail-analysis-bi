Package retail_analysis

Import bi.bi_types


System retail_analysis_bi: Application 

// A) Multidimensional model 

// A.1. Data Enumerations:

DataEnumeration enum_StoreTypes values (NewStore, SameStore)

// A.2. Dimensions:

DataEntity Districts "Districts Dimension" : Master : BI_Dimension [
  attribute districtID "DistrictID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute businessUnitID "BusinessUnitID" : Integer [constraints (NotNull)]
  attribute district "District" : String(50) [constraints (NotNull)]
  attribute DM "DM" : String(50) [constraints (NotNull)]
  attribute DMPic "DM Pic" : String(100) [constraints (NotNull)]
  attribute DMPicfl "DM Pic fl" : String(100) [constraints (NotNull)]
  attribute DMImage "DMImage" : String(100) [constraints (NotNull)]
  description "This dimension represents the various districts and associated attributes."
]

DataEntity Items "Items Dimension" : Master : BI_Dimension [
  attribute itemID "ItemID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute segment "Segment" : String(50) [constraints (NotNull)]
  attribute category "Category" : String(50) [constraints (NotNull)]
  attribute buyer "Buyer" : String(50) [constraints (NotNull)]
  attribute familyName "FamilyName" : String(50) [constraints (NotNull)]
  description "This dimension represents different types of items and their attributes."
]

DataEntity _Time "Time Dimension" : Reference : BI_Dimension [
  attribute reportingPeriodID "ReportingPeriodID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute period "Period" : String(20) [constraints (NotNull)]
  attribute fiscalYear "FiscalYear" : Integer [constraints (NotNull)]
  attribute fiscalMonth "FiscalMonth" : String(20) [constraints (NotNull)]
  attribute month "Month" : String(20) [constraints (NotNull)]
  description "This dimension provides different time attributes for reporting."
]

// A.3. Facts:

DataEntity Stores "Stores Fact": Transaction : BI_Fact [
  attribute locationID "Location ID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute cityName "City Name" : String(50) [constraints (NotNull)]
  attribute territory "Territory" : String(50) [constraints (NotNull)]
  attribute postalCode "Postal Code" : String(10) [constraints (NotNull)]
  attribute openDate "Open Date" : Date [constraints (NotNull)]
  attribute sellingAreaSize "Selling Area Size" : Decimal [constraints (NotNull)]
  attribute districtID "District ID" : Integer [constraints (NotNull ForeignKey(Districts))]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute storeNumber "Store Number" : Integer [constraints (NotNull)]
  attribute chain "Chain" : String(50) [constraints (NotNull)]
  attribute openYear "Open Year" : Integer [constraints (NotNull)]
  attribute storeType "Store Type" : DataEnumeration enum_StoreTypes [constraints (NotNull)]
  attribute openMonthNo "Open Month No" : Integer [constraints (NotNull)]
  attribute openMonth "Open Month" : String(20) [constraints (NotNull)]
  attribute averageSellingAreaSize "Average Selling Area Size" : Decimal [formula details: sum(sellingAreaSize) tag (name "expression" value "average(sellingAreaSize)")]
  attribute newStores "New Stores" : Integer [formula details: count(Stores) tag (name "expression" value "count(if(storeType = enum_StoreTypes.NewStore))")]
  attribute newStoresTarget "New Stores Target" : String(5) [defaultValue "14"]
  attribute openStoreCount "Open Store Count" : Integer [formula details: count(Stores) tag (name "expression" value "count(Store.openDate)")]
  attribute totalStores "Total Stores" : Integer [formula details: count(Stores)]
  description "This fact table represents various attributes and measures related to stores."
]

DataEntity Sales "Sales Fact" : Transaction : BI_Fact [
  attribute itemID "Item ID" : Integer [constraints (NotNull ForeignKey(Items))]
  attribute locationID "Location ID" : Integer [constraints (NotNull ForeignKey(Stores))]
  attribute reportingPeriodID "Reporting Period ID" : Integer [constraints (NotNull ForeignKey(_Time))]
  attribute monthID "Month ID" : Integer [constraints (NotNull)]
  attribute scenarioID "Scenario ID" : Integer [constraints (NotNull)]
  attribute sumGrossMarginAmount "Sum Gross Margin Amount" : Decimal [constraints (NotNull)]
  attribute sumMarkdownSalesDollars "Sum Markdown Sales Dollars" : Decimal [constraints (NotNull)]
  attribute sumMarkdownSalesUnits "Sum Markdown Sales Units" : Decimal [constraints (NotNull)]
  attribute sumRegularSalesDollars "Sum Regular Sales Dollars" : Decimal [constraints (NotNull)]
  attribute sumRegularSalesUnits "Sum Regular Sales Units" : Decimal [constraints (NotNull)]
  attribute lastYearSales "Last Year Sales" : Decimal [constraints (NotNull)]
  attribute markdownSalesDollars "Markdown Sales Dollars" : Decimal [formula details: sum(sumMarkdownSalesDollars)]
  attribute markdownSalesUnits "Markdown Sales Units" : Decimal [formula details: sum(sumMarkdownSalesUnits)]
  attribute regularSalesDollars "Regular Sales Dollars" : Decimal [formula details: sum(sumRegularSalesDollars)]
  attribute regularSalesUnits "Regular Sales Units" : Decimal [formula details: sum(sumRegularSalesUnits)]
  attribute salesPerSqFt "Sales Per Square Feet" : Decimal [formula details: sum(totalSales) tag (name "expression" value "TotalSales / (count(stores) * sum(sellingAreaSize))")]
  attribute storeCount "Store Count" : Integer [formula details: count(Stores)]
  attribute totalUnitsLastYear "Total Units Last Year" : Decimal [constraints (NotNull)]
  attribute totalUnitsThisYear "Total Units This Year" : Decimal [constraints (NotNull)]
  attribute totalSales "Total Sales" : Decimal [formula arithmetic (regularSalesDollars + Sales.markdownSalesDollars)]
  attribute totalSalesLY "Total Sales Last Year" : Decimal [constraints (NotNull)]
  attribute totalSalesTY "Total Sales This Year" : Decimal [constraints (NotNull)]
  attribute totalSalesVar "Total Sales Variance" : Decimal [formula arithmetic (totalSalesTY - totalSalesLY)]
  attribute totalSalesVarPercentage "Total Sales Variance %" : Decimal [formula arithmetic ((totalSalesVar / totalSalesLY) * 100) constraints (NotNull)]
  attribute averageUnitPrice "Average Unit Price" : Decimal [formula arithmetic (sumRegularSalesDollars / sumRegularSalesUnits) constraints (NotNull) tag (name "expression" value "average(sumRegularSalesDollars / sumRegularSalesUnits)")]
  attribute averageUnitPriceLastYear "Average Unit Price Last Year" : Decimal [formula arithmetic (lastYearSales / totalUnitsLastYear) constraints (NotNull) tag (name "expression" value "average(LastYearSales / TotalUnitsLastYear)")]
  attribute avgDollarPerUnitLastYear "Avg $/Unit LY" : Decimal [formula arithmetic (totalSalesLY / totalUnitsLastYear) constraints (NotNull)]
  attribute avgDollarPerUnitThisYear "Avg $/Unit TY" : Decimal [formula arithmetic (totalSalesTY / totalUnitsThisYear) constraints (NotNull)]
  attribute grossMarginLastYear "Gross Margin Last Year" : Decimal [formula arithmetic (lastYearSales - sumGrossMarginAmount) constraints (NotNull) tag (name "expression" value "sum(lastYearSales - sumGrossMarginAmount)")]
  attribute grossMarginLastYearPercentage "Gross Margin Last Year %" : Decimal [formula arithmetic ((grossMarginLastYear / totalSalesLY) * 100) constraints (NotNull)]
  attribute grossMarginThisYear "Gross Margin This Year" : Decimal [formula arithmetic (totalSalesTY - sumGrossMarginAmount) constraints (NotNull) tag (name "expression" value "sum(totalSalesTY - sumGrossMarginAmount)")]
  attribute grossMarginThisYearPercentage "Gross Margin This Year %" : Decimal [formula arithmetic ((grossMarginThisYear / totalSalesTY) * 100) constraints (NotNull)]
  description "This fact table represents various sales metrics, providing insights into sales performance, margins, and trends."
]

// A.4. Data Entities Clusters:

DataEntityCluster dec_Stores : Transaction [
    main Stores
    uses Districts    
]

DataEntityCluster dec_Sales : Transaction [
    main Sales
    uses Stores, Districts, _Time, Items
]

// B) Use Cases

// B.1. Actors:

Actor a_DM "Distric Manager" : User
Actor a_CFO "Chief Financial Officer" : User
Actor a_System_Administrator : User

// B.2. Use Cases:

UseCase uc_Analysis_Sales_National_Level_By_CFO : BIOperation : DataQuerying [
  actorInitiates a_CFO
  dataEntity dec_Sales

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown
  tag (name "BI-Action:BI_Slice:NationalSalesOverview" value "Dimensions:'_Time, Districts'")
  tag (name "BI-Action:BI_Dice:SalesByItemCategoryAndTime" value "Dimensions:'_Time, Items'")
  tag (name "BI-Action:BI_RollUp:SalesByDistrict" value "Dimensions:'Districts'")
  tag (name "BI-Action:BI_DrillDown:SalesDetailsByStore" value "Dimensions:'Stores'")

  description "Provides a comprehensive overview of sales and store data at a national level for the CFO"
]

UseCase uc_Analysis_Sales_District_Level_By_DM : BIOperation : DataQuerying [
  actorInitiates a_DM
  dataEntity dec_Sales

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown

  tag (name "BI-Action:BI_Slice:DistrictSalesOverview" value "Dimensions:'_Time, Districts'")
  tag (name "BI-Action:BI_Dice:SalesByItemInDistrict" value "Dimensions:'Districts, Items'")
  tag (name "BI-Action:BI_RollUp:SalesSummaryByTimeInDistrict" value "Dimensions:'_Time, Districts'")
  tag (name "BI-Action:BI_DrillDown:DetailedSalesByStoreInDistrict" value "Dimensions:'Stores, Districts'")

  description "Enables the District Manager to analyse sales and store data at a district level"
]

UseCase uc_Import_Last_Year_Financial_Data : BIOperation : DataImport [
  actorInitiates a_CFO
  dataEntity dec_Sales

  actions BI_Import 
]

UseCase uc_ Migrate_Database : BIOperation : DataExport [
  actorInitiates a_System_Administrator
  dataEntity dec_Sales

  actions BI_Export
]

// C) User Interface specification

UIContainer page_Overview "Overview" : Window : Page [
    component uiCo_This_Year_Sales_by_Chain "This Year Sales by Chain" : Chart : PieChart [
      dataBinding dec_Sales
      // The chart segments
      part Chain "Chain" : Field : Label [dataAttributeBinding Sales.Store.Chain]
      part TotalSalesTY "Total Sales This Year" : Field : Value [dataAttributeBinding Sales.totalSalesTY]

      event e_ShowHoverDetails : Submit : Submit_View
    ]

    component uiCo_New_Stores_Card "New Stores Card" : Card [
      dataBinding dec_Stores
    
      part NewStores "New Stores" : Field : Value [dataAttributeBinding Store.newStores]

      event e_RefreshData : Submit : Submit_Update [tag (name "Refresh" value "Refresh the new store's count")]
    ]

    component uiCo_Total_Stores_Card "Total Stores Card" : Card [
      dataBinding dec_Stores
    
      part TotalStores "Total Stores" : Field : Value [dataAttributeBinding Store.totalStores]

      event e_RefreshData : Submit : Submit_Update [tag (name "Refresh" value "Refresh the total store's count")]
    ]

    component uiCo_Total_Sales_Variance_by_FiscalMonth_and_District_Manager_BarChart : Chart : BarChart [
      dataBinding dec_Sales  
      // The chart axes
      part FiscalMonth "Fiscal Month" : Field : X_Axis [dataAttributeBinding Sales.Time.fiscalMonth]
      part TotalSalesVariance "Total Sales Variance" : Field : Y_Axis [dataAttributeBinding Sales.totalSalesVar]
      part DM "District Manager" : Field : Legend [dataAttributeBinding Sales.District.DM]

      event e_ShowHoverDetails : Submit : Submit_View
      event e_DrillDown : Submit : Submit_Update
      event e_RollUp : Submit : Submit_Update
    ]

    component uiCo_This_Year_Sales_by_PostalCode_and_Store_Type : Chart : GeographicalMap [
      dataBinding dec_Sales  
      // The map elements
      part PostalCode "Postal Code" : Field : Latitude [dataAttributeBinding Sales.Store.postalCode]
      part TotalSalesTY "Total Sales This Year" : Field : Longitude [dataAttributeBinding Sales.totalSalesTY]
      part StoreType "Store Type" : Field : Legend [dataAttributeBinding Sales.Store.storeType]

      event e_MapZoom : Submit : Submit_Update
      event e_MapPan : Submit : Submit_Update
      event e_DataUpdate : Submit : Submit_Update
      event e_ShowHoverDetails : Submit : Submit_View
    ]

    component uiCo_Total_Sales_Var_Percentage_Sales_Per_Sq_Ft_and_This_Year_Sales_by_District : Chart : ScatterPlot [
      dataBinding dec_Sales
      // The chart axes
      part SalesPerSqFt "Sales Per Sq Ft" : Field : X_Axis [dataAttributeBinding Sales.salesPerSqFt]
      part TotalSalesVariancePercentage "Total Sales Variance %" : Field : Y_Axis [dataAttributeBinding Sales.totalSalesVarPercentage]
      part District "District" : Field : Label [dataAttributeBinding Sales.District.districtID]

      event e_ShowHoverDetails : Submit_View
      event e_DrillDown : Submit : Submit_Update
      event e_RollUp : Submit : Submit_Update
    ]
]

UIContainer page_District_Monthly_Sales "Distric Monthly Sales" : Window : Page [
    component uiCo_Total_Sales_Variance_Percentage_by_FiscalMonth : Chart : BarChart [
      dataBinding dec_Sales
      // Chart axes
      part FiscalMonth "Fiscal Month" : Field : X_Axis [dataAttributeBinding Sales._Time.fiscalMonth]
      part TotalSalesVariancePercentage "Total Sales Variance %" : Field : Y_Axis [dataAttributeBinding Sales.totalSalesVarPercentage]

      event e_ShowHoverDetails : Submit : Submit_View
      event e_DrillDown : Submit : Submit_Update
      event e_RollUp : Submit : Submit_Update
    ]
    
    component uiCo_This_Year_Sales_by_Store_Number_Name : Chart : BarChart [
      dataBinding dec_Sales
      // Chart axes
      part StoreNumberName "Store Number Name" : Field : X_Axis [dataAttributeBinding Sales.Store.Name]
      part TotalSalesTY "Total Sales This Year" : Field : Y_Axis [dataAttributeBinding Sales.totalSalesTY]

      event e_ShowHoverDetails : Submit : Submit_View
      event e_DrillDown : Submit : Submit_Update
      event e_RollUp : Submit : Submit_Update
    ]

    component uiCo_Last_Year_Sales_and_This_Year_Sales_by_FiscalMonth : Chart : AreaChart [
      dataBinding dec_Sales
      // Chart axes
      part sales_date : Field : X_Axis [dataAttributeBinding e_Sales.reportingPeriodID]
      part lastYearSales : Field : Y_Axis [dataAttributeBinding e_Sales.lastYearSales]
      part thisYearSales : Field : Y_Axis [dataAttributeBinding e_Sales.thisYearSales]

      event e_DrillDown : Submit : Submit_Update
      event e_RollUp : Submit : Submit_Update
      event e_ShowHoverDetails : Submit : Submit_View
    ]

    component uiCo_Total_Sales_Var_Percentage_Avg_Unit_TY_and_This_Year_Sales_by_Category : Chart : ScatterPlot [
      dataBinding dec_Sales  
      // Chart axes
      part AverageUnitPrice "Average Unit Price" : Field : X_Axis [dataAttributeBinding Sales.averageUnitPrice]
      part TotalSalesVariancePercentage "Total Sales Variance %" : Field : Y_Axis [dataAttributeBinding Sales.totalSalesVarPercentage]
      part Category "Category" : Field : Label [dataAttributeBinding Item.category]

      event e_ShowHoverDetails : Submit : Submit_View
      event e_DrillDown : Submit : Submit_Update
      event e_RollUp : Submit : Submit_Update
    ]
    // Filter
    component fi_District_Manager_Filter "District Manager Filter" : Filter : Dropdown [
      dataBinding dec_Stores
  
      part DM "District Manager" : Field : Option [dataAttributeBinding Store.DistrictID.DM]

      event e_ApplyFilter : Submit : Submit_Update [tag (name "DM Slice" value "Slice Districts by their district manager")]
      event e_ResetFilter : Submit : Submit_Update [tag (name "Reset" value "Clear the district manager filter")]
    ]
]

UIContainer page_New_Stores "New Stores" : Window : Page [
    component uiCo_This_Year_Sales_by_City_and_Chain : Chart : GeographicalMap [
      dataBinding dec_Sales
      // Chart layers
      part City "City" : Field : Location [dataAttributeBinding Store.cityName]
      part Chain "Chain" : Field : Legend [dataAttributeBinding Store.chain]
      part ThisYearSales "This Year Sales" : Field : Value [dataAttributeBinding Sales.totalSalesTY]

      event e_MapZoom : Submit : Submit_Update
      event e_MapPan : Submit : Submit_Update
      event e_DataUpdate : Submit : Submit_Update
      event e_ShowHoverDetails : Submit : Submit_View
    ]

    component uiCo_Open_Store_Count_by_Open_Month_and_Chain : Chart : BarChart [
      dataBinding dec_Sales
      // Chart axes
     part OpenMonth "Open Month" : Field : X_Axis [dataAttributeBinding Sales._Time.month]
     part Chain "Chain" : Field : Y_Axis [dataAttributeBinding Sales.Store.chain]
     part OpenStoreCount "Open Store Count" : Field : Y_Axis [dataAttributeBinding Sales.Store.openStoreCount]

     event e_ShowHoverDetails : Submit : Submit_View
     event e_DrillDown : Submit : Submit_Update
     event e_RollUp : Submit : Submit_Update
   ]

   component uiCo_Sales_Per_Sq_Ft_by_Name : Chart : BarChart [
     dataBinding dec_Sales
     // Chart axes
     part StoreName "Store Name" : Field : X_Axis [dataAttributeBinding Store.Name]
     part SalesPerSqFt "Sales Per Sq Ft" : Field : Y_Axis [dataAttributeBinding Sales.salesPerSqFt]

     event e_ShowHoverDetails : Submit : Submit_View
     event e_DrillDown : Submit : Submit_Update
     event e_RollUp : Submit : Submit_Update
   ]

   component uiCo_This_Year_Sales_by_FiscalMonth : Chart : LineChart [
     dataBinding dec_Sales
     // Chart axes
     part FiscalMonth "Fiscal Month" : Field : X_Axis [dataAttributeBinding Sales._Time.fiscalMonth]
     part ThisYearSales "This Year Sales" : Field : Y_Axis [dataAttributeBinding Sales.totalSalesTY]

     event e_ShowHoverDetails : Submit : Submit_View
     event e_DataUpdate : Submit : Submit_Update
   ]
    // Filter
    component fi_New_Stores_Name_Filter "New Stores Name Filter" : Filter : Dropdown [
      dataBinding dec_Stores
  
      part StoreName "Store Name" : Field : Option [dataAttributeBinding Store.Name]

      event e_ApplyFilter : Submit : Submit_Update [tag (name "Stores Slice" value "Slice Stores by their name")]
      event e_ResetFilter : Submit : Submit_Update [tag (name "Reset" value "Clear the new store's filter")]
    ]
]
