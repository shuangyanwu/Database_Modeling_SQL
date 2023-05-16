#1: An Airbnb host wants to check important rules that appear in every airbnb and show all available 
# translated versions for those rules. Language, ruleID, and TranslatedRuleid are also shown, results are ordered by language.

SELECT 
    language, ruleid, TranslatedRuleid, TranslationText
FROM
    TranslatedRule
WHERE
    ruleid IN (SELECT 
            rule.ruleid
        FROM
            rule
        WHERE
            NOT EXISTS( SELECT 
                    *
                FROM
                    airbnb
                WHERE
                    NOT EXISTS( SELECT 
                            *
                        FROM
                            airbnbRule,
                            TranslatedRule
                        WHERE
                            airbnb.airbnbID = airbnbRule.airbnbID
                                AND TranslatedRule.ruleid = rule.ruleid
                                AND airbnbRule.TranslatedRuleid = TranslatedRule.TranslatedRuleid)))
ORDER BY language;

#2: The rules that have the word “pet” or “smoking” are common rules, it may be more user friendly to have these rules 
# in several different languages. So, the numbers of their translated rules are counted and presented together with the ruleID and ruleText.

SELECT
rule.ruleID,
ruleText,
COUNT(TranslatedRuleid) AS TranslationCount
FROM
TranslatedRule,
rule WHERE
rule.ruleID = TranslatedRule.ruleId AND rule.ruleID IN (SELECT
rule.ruleID FROM
rule WHERE
ruleText REGEXP 'pet|smoking') GROUP BY rule.ruleID;

