module ISX.Plug.CrawlerHTML.Zone.Common.DataSpec (spec) where


import              ISX.Test
import              Prelude                                 hiding  (get)
import qualified    Data.HashMap.Strict                     as  HM
import qualified    Data.Map.Strict                         as  M


spec :: Spec
spec =
    describe "/data POST" $ do
        it "ok" $ do
            res <- withSrv $ postJSON "/data" pC
            assertSuccess res
            b <- getResponseBody res
            b ^. key "data" . key "header" . _Object `shouldBe` HM.empty
            b ^? key "data" . key "status" . _Integer `shouldBe` Nothing
            length (b ^. key "data" . _Object) `shouldBe` 2
            length (b ^. key "urls" . _Array) `shouldBe` 0
            assertElemN res 2
        
        it "ok header" $ do
            let pC' = mergeObject pC $ object [
                    ("header", object [
                        ("Content-Type", "application/pdf")])]
            res <- withSrv $ postJSON "/data" pC'
            assertSuccess res
            b <- getResponseBody res
            b ^. key "data" . key "header" . key "Content-Type" . _String `shouldBe` "application/pdf"
            b ^? key "data" . key "status" . _Integer `shouldBe` Nothing
            length (b ^. key "data" . _Object) `shouldBe` 2
            length (b ^. key "urls" . _Array) `shouldBe` 0
            assertElemN res 2
        
        it "ok status" $ do
            let pC' = mergeObject pC $ object [
                    ("meta", object [
                        ("status", Number 418)])]
            res <- withSrv $ postJSON "/data" pC'
            assertSuccess res
            b <- getResponseBody res
            b ^. key "data" . key "header" . _Object `shouldBe` HM.empty
            b ^? key "data" . key "status" . _Integer `shouldBe` Just 418
            length (b ^. key "data" . _Object) `shouldBe` 2
            length (b ^. key "urls" . _Array) `shouldBe` 0
            assertElemN res 2
        
        describe "www.pavouk.tech" $
            it "apex" $
                testPage "www.pavouk.tech/"


pC :: Value
pC = object [
    ("meta", object [
        ("url", "http://example.com:80/")]),
    ("header", object []),
    ("body", String "")]

testPage :: Text -> IO ()
testPage url = do
    procI <- fPlugProcI url 200 M.empty
    res <- withSrv $ postJSON "/data" procI
    assertSuccess res
    b <- getResponseBody res
    b ^. key "data" . key "header" . _Object `shouldBe` HM.empty
    b ^? key "data" . key "status" . _Integer `shouldBe` Just 200
    length (b ^. key "data" . _Object) `shouldBe` 2
    assertResultsLookup (b ^. key "urls" . _Array) url
    assertElemN res 2
