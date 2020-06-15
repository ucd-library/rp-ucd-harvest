<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ *******************************************************************************
  ~   Copyright (c) 2019 Symplectic. All rights reserved.
  ~   This Source Code Form is subject to the terms of the Mozilla Public
  ~   License, v. 2.0. If a copy of the MPL was not distributed with this
  ~   file, You can obtain one at http://mozilla.org/MPL/2.0/.
  ~ *******************************************************************************
  ~   Version :  ${git.branch}:${git.commit.id}
  ~ *******************************************************************************
  -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:bibo="http://purl.org/ontology/bibo/"
                xmlns:vivo="http://vivoweb.org/ontology/core#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:score="http://vivoweb.org/ontology/score#"
                xmlns:ufVivo="http://vivo.ufl.edu/ontology/vivo-ufl/"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#"
                xmlns:api="http://www.symplectic.co.uk/publications/api"
                xmlns:symp="http://www.symplectic.co.uk/vivo/"
                xmlns:svfn="http://www.symplectic.co.uk/vivo/namespaces/functions"
                xmlns:config="http://www.symplectic.co.uk/vivo/namespaces/config"
                xmlns:obo="http://purl.obolibrary.org/obo/"
                exclude-result-prefixes="rdf rdfs bibo vivo foaf score ufVivo vitro api obo symp svfn config xs"
        >

    <!-- Import XSLT files that are used -->
    <xsl:import href="elements-to-vivo-utils.xsl" />

    <xsl:template match="api:relationship[@type='activity-user-association' and api:related/api:object[@category='activity' and @type='distinction']]" mode="visible-relationship">
        <xsl:variable name="contextURI" select="svfn:relationshipURI(.,'relationship')" />

        <xsl:variable name="activityObj" select="svfn:fullObject(api:related/api:object[@category='activity'])" />
        <xsl:variable name="userObj" select="svfn:fullObject(api:related/api:object[@category='user'])" />

        <!-- should probably only break out an actual award object for awards/honours that are prestigious/well known - implement a dictionary a la organisations? -->
        <xsl:variable name="awardName" select="svfn:getRecordField($activityObj,'title')" />
        <xsl:if test="$awardName/api:text">
            <xsl:variable name="awardURI"><xsl:value-of select="svfn:makeURI('award-',$awardName/api:text)" /></xsl:variable>

            <xsl:variable name="userURI" select="svfn:userURI($userObj)" />

            <!-- An Award-->
            <xsl:call-template name="render_rdf_object">
                <xsl:with-param name="objectURI" select="$awardURI" />
                <xsl:with-param name="rdfNodes">
                    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Award"/>
                    <xsl:copy-of select="svfn:renderPropertyFromField($activityObj,'rdfs:label','title')" />
                    <vivo:relatedBy rdf:resource="{$contextURI}"/><!-- Context object -->
                </xsl:with-param>
            </xsl:call-template>

            <!-- Awarding Agent -->
            <xsl:variable name="awardedBy" select="svfn:getRecordField($activityObj,'institution')" />
            <xsl:for-each select="$awardedBy/api:addresses/api:address">
                <xsl:variable name="orgObjects" select="svfn:organisationObjects(.)" />
                <xsl:variable name="orgURI" select="svfn:organisationObjectsMainURI($orgObjects)" />

                <xsl:variable name="hasLinkedOrg" select="$orgURI and $orgURI != ''" />

                <xsl:if test="$hasLinkedOrg">
                    <xsl:copy-of select="$orgObjects" />
                    <!-- Add context object link -->
                    <xsl:call-template name="render_rdf_object">
                        <xsl:with-param name="objectURI" select="$contextURI" />
                        <xsl:with-param name="rdfNodes">
                            <vivo:assignedBy rdf:resource="{$orgURI}"/><!-- Awarding Agent -->
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>

            <!-- Context Object -->
            <!-- render datetime interval to intermediate variable, retrieve uri for reference purposes and then render variable contents-->
            <xsl:variable name="awardDate" select="svfn:getRecordField($activityObj,'start-date')" />
            <xsl:variable name="endDate" select="svfn:getRecordField($activityObj,'end-date')" />
            <!-- we only create a dateInterval if there is an end date in this case. -->
            <xsl:variable name="dateInterval">
                <xsl:if test="$endDate/*">
                    <xsl:copy-of select="svfn:renderDateInterval($contextURI, $awardDate , $endDate, '', false())" />
                </xsl:if>
            </xsl:variable>

            <xsl:variable name="dateIntervalURI" select="svfn:retrieveDateIntervalUri($dateInterval)" />
            <xsl:copy-of select="$dateInterval" />

            <xsl:variable name="yearAwardedURI" select="concat($contextURI,'-awarded')" />
            <xsl:if test="$awardDate/*">
                <xsl:copy-of select="svfn:renderDateObject($yearAwardedURI, $awardDate, '')" />
            </xsl:if>

            <xsl:call-template name="render_rdf_object">
                <xsl:with-param name="objectURI" select="$contextURI" />
                <xsl:with-param name="rdfNodes">
                    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#AwardReceipt"/>
                    <rdfs:label>
                        <xsl:apply-templates select="$awardName" />
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="svfn:distinctionReceiptUserLabel($userObj)" />
                        <xsl:if test="$awardDate/*">
                            <xsl:text> - </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$awardDate/api:date/api:year" />
                        <xsl:text>)</xsl:text>
                    </rdfs:label>
                    <xsl:copy-of select="svfn:renderPropertyFromField($activityObj,'vivo:description','description')" />
                    <vivo:relates rdf:resource="{$awardURI}"/><!-- Award -->
                    <vivo:relates rdf:resource="{$userURI}"/><!-- User -->
                    <xsl:if test="$awardDate/*">
                        <vivo:dateTimeValue rdf:resource="{$yearAwardedURI}"/><!-- Year Awarded -->
                        <xsl:if test="$dateInterval/*">
                            <vivo:dateTimeInterval rdf:resource="{$dateIntervalURI}"/><!-- Years Inclusive -->
                        </xsl:if>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>

            <!-- Relate user to context-->
            <xsl:call-template name="render_rdf_object">
                <xsl:with-param name="objectURI" select="$userURI" />
                <xsl:with-param name="rdfNodes">
                    <vivo:relatedBy rdf:resource="{$contextURI}"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:function name="svfn:distinctionReceiptUserLabel">
        <xsl:param name="user" />
        <xsl:value-of select="svfn:userLabel($user)" />
    </xsl:function>

</xsl:stylesheet>