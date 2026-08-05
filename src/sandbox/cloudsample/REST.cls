Class Sandbox.Cloudsample.REST Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

XData UrlMap
{
<Routes>
    <Route Url="/test" Method="GET" Call="Test"/>
</Routes>
}

ClassMethod Test() As %Status
{
    set jo = {
        "status": "OK"
    }
    write jo.%ToJSON()
    return $$$OK
}

}
