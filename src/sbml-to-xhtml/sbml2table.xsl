<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2016-2020 InSysBio, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<!-- INFO
Description: Creating representation of whole sbml into table format.
Source files: SBML L2 V1-5
modes:
  - table
  - reactionFormula
  - idOrName
  - unitFormula/unitFormulaScale
  - link/no-link
  - element

Author: Evgeny Metelkin
Project-page: http://sv.insysbio.com
-->
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:l2v1="http://www.sbml.org/sbml/level2"
  xmlns:l2v2="http://www.sbml.org/sbml/level2/version2"
  xmlns:l2v3="http://www.sbml.org/sbml/level2/version3"
  xmlns:l2v4="http://www.sbml.org/sbml/level2/version4"
  xmlns:l2v5="http://www.sbml.org/sbml/level2/version5"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="mml xhtml l2v1 l2v2 l2v3 l2v4 l2v5">

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>

  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->
  <xsl:param name="equationsOff">false</xsl:param> <!-- do not show equations -->

  <!-- top -->
  <xsl:template match="/">
    <xsl:apply-templates mode="table"/>
  </xsl:template>

  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="table">
    <div class="sbml-element sbml-sbml sv-container sv-mode-table">
      <h1 class="sv-header">SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/></h1>
      <div class="sv-content">
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='model']" mode="table"/>
      </div>
    </div>
  </xsl:template>

  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="table">
    <div class="sbml-element sbml-model sv-container">
      <h2 class="sv-header">Model</h2>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <xsl:apply-templates select="*[contains(local-name(), 'listOf')]" mode="table"/>
      </div>
    </div>
  </xsl:template>

  <!-- annotation -->
  <xsl:template match="*[local-name()='annotation']" mode="element">
    <div class="sbml-element sbml-annotation sv-container">
      <p class="sv-header sbml-element-name">Annotation</p>
      <pre class="sv-content sv-raw-xml prettyprint"><xsl:copy-of select="node()"/></pre>
    </div>
  </xsl:template>

  <!-- notes -->
  <xsl:template match="*[local-name()='notes']" mode="element">
    <div class="sbml-element sbml-notes sv-container">
      <p class="sv-header sbml-element-name">Notes</p>
      <div class="sv-content sv-xhtml">
        <xsl:copy-of select="node()"/>
      </div>
    </div>
  </xsl:template>

<!--
  <xsl:template match="*[local-name()='notes' and xhtml:body]" mode="element">
   <p><strong>notes:</strong></p>
   <div class="note-content">
    <xsl:copy-of select="xhtml:body/node()"/>
   </div>
  </xsl:template>

  <xsl:template match="*[local-name()='notes' and xhtml:html[xhtml:body]]" mode="element">
   <p><strong>notes:</strong></p>
   <div class="note-content">
    <xsl:copy-of select="xhtml:html/xhtml:body/node()"/>
   </div>
  </xsl:template>
-->

  <!-- @attributes -->
  <xsl:template match="@*" mode="element">
    <p>
      <xsl:attribute name="class">sbml-attribute sbml-<xsl:value-of select="local-name()"/> sv-container</xsl:attribute>
      <span class="sbml-attribute-name"><xsl:value-of select="local-name()"/></span>: <span class="sbml-attribute-value"><xsl:value-of select="."/></span>
    </p>
  </xsl:template>

  <!-- id -->
  <xsl:template match="@id" mode="link">
    <span class="sbml-attribute-value sbml-id">
      <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="@id" mode="no-link">
    <span class="sbml-attribute-value sbml-id">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

	<!-- SId object: internal ref -->
  <xsl:template
    match="@species
      |@substanceUnits
      |@units
      |@compartment
      |@speciesType
      |@compartmentType
      |@outside
      |@symbol
      |@variable">
    <xsl:if test="not(key('idKey',.))">
      <span>
        <xsl:attribute name="class">sbml-attribute-value sbml-<xsl:value-of select="local-name()"/> sbml-id-lost</xsl:attribute>
        <xsl:value-of select="."/>
      </span>
    </xsl:if>

    <xsl:if test="key('idKey',.)">
      <span>
        <xsl:attribute name="class">sbml-attribute-value sbml-<xsl:value-of select="local-name()"/> sbml-id-ref</xsl:attribute>
        <xsl:apply-templates select="key('idKey',.)/@id" mode="idOrName"/>
      </span>
    </xsl:if>
  </xsl:template>

  <!-- listOfFunctionDefinitions -->
  <xsl:template match="*[local-name()='listOfFunctionDefinitions']" mode="table">
    <div class="sbml-listOf sbml-listOfFunctionDefinitions sv-container">
      <h3 class="sv-header">listOfFunctionDefinitions:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>id</th>
            <th><xsl:if test="*/@name">name</xsl:if></th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th>math</th>
          </tr>
          <xsl:apply-templates select="*[local-name()='functionDefinition']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='functionDefinition']" mode="table">
      <tr class="sbml-element sbml-functionDefinition">
        <td><xsl:apply-templates select="@id" mode="no-link"/></td>
        <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
        <td class="sbml-attribute-value sbml-metaid"><xsl:apply-templates select="@metaid" mode="table"/></td>
        <td class="sbml-element sbml-math sv-mml"><xsl:apply-templates select="mml:math"/></td>
      </tr>
      <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
      <tr class="sbml-mixed sv-hidden">
        <td colspan="4">
          <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
          <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
        </td>
      </tr>
      </xsl:if>
  </xsl:template>

  <!-- listOfUnitDefinitions -->
  <xsl:template match="*[local-name()='listOfUnitDefinitions']" mode="table">
    <div class="sbml-listOf sbml-listOfUnitDefinitions sv-container">
      <h3 class="sv-header">listOfUnitDefinitions:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
        <tr>
          <th>id</th>
          <th><xsl:if test="*/@name">name</xsl:if></th>
          <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
          <th>listOfUnits</th>
        </tr>
        <xsl:apply-templates select="*[local-name()='unitDefinition']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='unitDefinition']" mode="table">
      <tr class="sbml-element sbml-unitDefinition">
        <td><xsl:apply-templates select="@id" mode="no-link"/></td>
        <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
        <td class="sbml-attribute-value sbml-metaid"><xsl:apply-templates select="@metaid" mode="table"/></td>
        <td class="sbml-listOf sbml-listOfUnitDefinition"><xsl:apply-templates select="*[local-name()='listOfUnits']" mode="unitFormula"/></td>
      </tr>
      <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
      <tr class="sbml-mixed sv-hidden">
        <td colspan="4">
          <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
          <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
        </td>
      </tr>
      </xsl:if>
  </xsl:template>

  <!-- listOfCompartmentTypes -->
  <xsl:template match="*[local-name()='listOfCompartmentTypes']" mode="table">
    <div class="sbml-listOf sbml-listOfCompartmentTypes sv-container">
      <h3 class="sv-header">listOfCompartmentTypes:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>id</th>
            <th><xsl:if test="*/@name">name</xsl:if></th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
          </tr>
          <xsl:apply-templates select="*[local-name()='compartmentType']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='compartmentType']" mode="table">
    <tr class="sbml-element sbml-compartmentType">
      <td><xsl:apply-templates select="@id" mode="no-link"/></td>
      <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="3">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfSpeciesTypes -->
  <xsl:template match="*[local-name()='listOfSpeciesTypes']" mode="table">
    <div class="sbml-listOf sbml-listOfSpeciesTypes sv-container">
      <h3 class="sv-header">listOfSpeciesTypes:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
        <tr>
          <th>id</th>
          <th><xsl:if test="*/@name">name</xsl:if></th>
          <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
        </tr>
        <xsl:apply-templates select="*[local-name()='speciesType']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='speciesType']" mode="table">
    <tr class="sbml-element sbml-speciesType">
      <td><xsl:apply-templates select="@id" mode="no-link"/></td>
      <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:apply-templates select="@metaid" mode="table"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="3">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfCompartments -->
  <xsl:template match="*[local-name()='listOfCompartments']" mode="table">
    <div class="sbml-listOf sbml-listOfCompartments sv-container">
      <h3 class="sv-header">listOfCompartments:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table class="sv-listof-table">
        <tr>
          <th>id</th>
          <th><xsl:if test="*/@name">name</xsl:if></th>
          <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
          <th><xsl:if test="*/@constant">constant</xsl:if></th>
          <th><xsl:if test="*/@compartmentType">compartment Type</xsl:if></th>
          <th><xsl:if test="*/@outside">outside</xsl:if></th>
          <th><xsl:if test="*/@units">units</xsl:if></th>
          <th><xsl:if test="*/@size">size</xsl:if></th>
          <th><xsl:if test="*/@spatialDimensions">spatial Dimensions</xsl:if></th>
        </tr>
        <xsl:apply-templates select="*[local-name()='compartment']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment']" mode="table">
      <tr class="sbml-element sbml-compartment">
        <td><xsl:apply-templates select="@id" mode="link"/></td>
        <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
        <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
        <td class="sbml-attribute-value sbml-constant"><xsl:value-of select="@constant"/></td>
        <td class="sbml-attribute-value sbml-compartment"><xsl:apply-templates select="@compartmentType"/></td>
        <td class="sbml-attribute-value sbml-outside"><xsl:apply-templates select="@outside"/></td>
        <td class="sbml-attribute-value sbml-units"><xsl:apply-templates select="@units"/></td>
        <td class="sbml-attribute-value sbml-size"><xsl:value-of select="@size"/></td>
        <td class="sbml-attribute-value sbml-spatialDimensions"><xsl:value-of select="@spatialDimensions"/></td>
      </tr>
      <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
      <tr class="sbml-mixed sv-hidden">
        <td colspan="7">
          <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
          <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
        </td>
      </tr>
      </xsl:if>
  </xsl:template>

  <!-- listOfSpecies -->
  <xsl:template match="*[local-name()='listOfSpecies']" mode="table">
    <div class="sbml-listOf sbml-listOfSpecies sv-container">
      <h3 class="sv-header">listOfSpecies:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>id</th>
            <th><xsl:if test="*/@name">name</xsl:if></th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th><xsl:if test="*/@constant">constant</xsl:if></th>
            <th><xsl:if test="*/@speciesType">speciesType</xsl:if></th>
            <th><xsl:if test="*/@substanceUnits">substance Units</xsl:if></th>
            <th><xsl:if test="*/@hasOnlySubstanceUnits">hasOnly Substance Units</xsl:if></th>
            <th><xsl:if test="*/@initialConcentration">initial Concentration</xsl:if></th>
            <th><xsl:if test="*/@initialAmount">initial Amount</xsl:if></th>
            <th><xsl:if test="*/@boundaryCondition">boundary Condition</xsl:if></th>
            <th><xsl:if test="*/@compartment">compartment</xsl:if></th>
            <th><xsl:if test="*/@charge">charge</xsl:if></th>
          </tr>
          <xsl:apply-templates select="*[local-name()='species']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='species']" mode="table">
    <tr class="sbml-element sbml-species">
      <td><xsl:apply-templates select="@id" mode="link"/></td>
      <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-attribute-value sbml-constant"><xsl:value-of select="@constant"/></td>
      <td class="sbml-attribute-value sbml-speciesType"><xsl:apply-templates select="@speciesType"/></td>
      <td class="sbml-attribute-value sbml-substanceUnits"><xsl:apply-templates select="@substanceUnits"/></td>
      <td class="sbml-attribute-value sbml-hasOnlySubstanceUnits"><xsl:value-of select="@hasOnlySubstanceUnits"/></td>
      <td class="sbml-attribute-value sbml-initialConcentration"><xsl:value-of select="@initialConcentration"/></td>
      <td class="sbml-attribute-value sbml-initialAmount"><xsl:value-of select="@initialAmount"/></td>
      <td class="sbml-attribute-value sbml-boundaryCondition"><xsl:value-of select="@boundaryCondition"/></td>
      <td class="sbml-attribute-value sbml-compartment"><xsl:apply-templates select="@compartment"/></td>
      <td class="sbml-attribute-value sbml-charge"><xsl:value-of select="@charge"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="11">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfParameters -->
  <xsl:template match="*[local-name()='listOfParameters']" mode="table">
    <div class="sbml-listOf sbml-listOfParameters sv-container">
      <h3 class="sv-header">listOfParameters:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>id</th>
            <th><xsl:if test="*/@name">name</xsl:if></th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th><xsl:if test="*/@constant">constant</xsl:if></th>
            <th><xsl:if test="*/@units">units</xsl:if></th>
            <th><xsl:if test="*/@value">value</xsl:if></th>
          </tr>
          <xsl:apply-templates select="*[local-name()='parameter']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter']" mode="table">
    <tr class="sbml-element sbml-parameter">
      <td><xsl:apply-templates select="@id" mode="link"/></td>
      <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-attribute-value sbml-constant"><xsl:value-of select="@constant"/></td>
      <td class="sbml-attribute-value sbml-units"><xsl:apply-templates select="@units"/></td>
      <td class="sbml-attribute-value sbml-value"><xsl:value-of select="@value"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="5">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfInitialAssignments annotation -->
  <xsl:template match="*[local-name()='listOfInitialAssignments']" mode="table">
    <div class="sbml-listOf sbml-listOfInitialAssignments sv-container">
      <h3 class="sv-listof-header">listOfInitialAssignments:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>symbol</th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th>math:</th>
          </tr>
          <xsl:apply-templates select="*[local-name()='initialAssignment']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='initialAssignment']" mode="table">
    <tr class="sbml-element sbml-initialAssignment">
      <td><xsl:apply-templates select="@symbol"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-element sbml-math sv-mml"><xsl:apply-templates select="mml:math"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="3">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfConstraints annotation -->
  <xsl:template match="*[local-name()='listOfConstraints']" mode="table">
    <div class="sbml-listOf sbml-listOfConstraints sv-container">
      <h3 class="sv-header">listOfConstraints:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
        <tr>
          <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
          <th><xsl:if test="*/*[local-name()='message']">message</xsl:if></th>
          <th>math:</th>
        </tr>
          <xsl:apply-templates select="*[local-name()='constraint']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='constraint']" mode="table">
    <tr class="sbml-element sbml-constraint">
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-element sbml-message"><xsl:apply-templates select="*[local-name()='message']" mode="table"/></td>
      <td class="sbml-element sbml-math sv-mml"><xsl:apply-templates select="mml:math"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="3">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfRules annotation -->
  <xsl:template match="*[local-name()='listOfRules']" mode="table">
    <div class="sbml-listOf sbml-listOfRules sv-container">
      <h3 class="sv-header">listOfRules:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
        <tr>
    	    <th>type</th>
          <th>variable</th>
          <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
          <th>math:</th>
        </tr>
        <xsl:apply-templates select="*[local-name()='assignmentRule'] | *[local-name()='algebraicRule'] | *[local-name()='rateRule']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='assignmentRule']
    |*[local-name()='algebraicRule']
    |*[local-name()='rateRule']" mode="table">
    <tr>
      <xsl:attribute name="class">sbml-element sbml-<xsl:value-of select="local-name()"/></xsl:attribute>
      <td><xsl:value-of select="local-name()"/></td>
      <td><xsl:apply-templates select="@variable"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-element sbml-math sv-mml"><xsl:apply-templates select="mml:math"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="4">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfReactions annotation -->
  <xsl:template match="*[local-name()='listOfReactions']" mode="table">
    <div class="sbml-listOf sbml-listOfReactions sv-container">
      <h3 class="sv-header">listOfReactions:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>id</th>
            <th><xsl:if test="*/@name">name</xsl:if></th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th>reactants/products:</th>
            <th><xsl:if test="*/*[local-name()='listOfModifiers']">modifiers:</xsl:if></th>
            <th>math:</th>
          </tr>
          <xsl:apply-templates select="*[local-name()='reaction']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']" mode="table">
    <tr class="sbml-element sbml-functionDefinition">
      <td><xsl:apply-templates select="@id" mode="link"/></td>
      <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-mixed"><xsl:apply-templates select="." mode="reactionFormula"/></td>
      <td class="sbml-listOf sbml-listOfModifiers"><xsl:apply-templates select="*[local-name()='listOfModifiers']" mode="reactionFormula"/></td>
      <td class="sbml-element sbml-math sv-mml"><xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']|*[local-name()='kineticLaw']/*[local-name()='listOfParameters']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="6">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='kineticLaw']/*[local-name()='listOfParameters']" mode="table"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <!-- listOfEvents annotation -->
  <xsl:template match="*[local-name()='listOfEvents']" mode="table">
    <div class="sbml-listOf sbml-listOfEvents sv-container">
      <h3 class="sv-header">listOfEvents:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>id</th>
            <th><xsl:if test="*/@name">name</xsl:if></th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th><xsl:if test="*/@useValuesFromTriggerTime">useValuesFrom TriggerTime</xsl:if></th>
            <th>trigger</th>
            <th>delay</th>
          </tr>
          <xsl:apply-templates select="*[local-name()='event']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='event']" mode="table">
    <tr class="sbml-element sbml-event">
      <td><xsl:apply-templates select="@id" mode="no-link"/></td>
      <td class="sbml-attribute-value sbml-name"><xsl:value-of select="@name"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-attribute-value sbml-useValuesFromTriggerTime"><xsl:value-of select="@useValuesFromTriggerTime"/></td>
      <td class="sbml-element sbml-trigger sbml-math sv-mml"><xsl:apply-templates select="*[local-name()='trigger']" mode="table"/></td>
      <td class="sbml-element sbml-delay sbml-math sv-mml"><xsl:apply-templates select="*[local-name()='delay']" mode="table"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']
      |./*[local-name()='annotation']
      |*[local-name()='listOfEventAssignments']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="6">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='listOfEventAssignments']" mode="table"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[local-name()='trigger']" mode="table">
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>

  <xsl:template match="*[local-name()='delay']" mode="table">
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>

  <!-- listOfEventAssignments annotation -->
  <xsl:template match="*[local-name()='listOfEventAssignments']" mode="table">
    <div class="sbml-listOf sbml-listOfEventAssignments sv-container">
      <h3 class="sv-header">listOfEventAssignments:</h3>
      <div class="sbml-mixed sv-content">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <table>
          <tr>
            <th>variable</th>
            <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
            <th>math:</th>
          </tr>
          <xsl:apply-templates select="*[local-name()='eventAssignment']" mode="table"/>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='eventAssignment']" mode="table">
    <tr class="sbml-element sbml-eventAssignment">
      <td><xsl:apply-templates select="@variable"/></td>
      <td class="sbml-attribute-value sbml-metaid"><xsl:value-of select="@metaid"/></td>
      <td class="sbml-element sbml-math sv-mml"><xsl:apply-templates select="mml:math"/></td>
    </tr>
    <xsl:if test="./*[local-name()='notes']|./*[local-name()='annotation']">
    <tr class="sbml-mixed sv-hidden">
      <td colspan="3">
        <xsl:apply-templates select="./*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
      </td>
    </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[local-name()='unitDefinition']/@name" mode="table">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- message type: just copy -->
  <xsl:template match="*[local-name()='message']" mode="table">
    <xsl:copy-of select="node()"/>
  </xsl:template>

  <!-- do nothing if nothing to output-->
  <xsl:template match="*" mode="table">
    = missing in xslt: <xsl:value-of select="local-name()"/>=
  </xsl:template>

<!-- END OF table mode -->

<!-- BEGIN OF unitFormula/unitFormulaScale mode -->
    <xsl:template match="l2v2:listOfUnits
      | l2v3:listOfUnits
      | l2v4:listOfUnits
      | l2v5:listOfUnits" mode="unitFormula">
      <xsl:apply-templates select="*[local-name()='unit']" mode="unitFormula"/>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and @exponent!='1']" mode="unitFormula">
        (<xsl:if test="@multiplier!='1'"><xsl:value-of select="@multiplier"/>&#8901;</xsl:if><xsl:if test="@scale!='0'">10<sup><xsl:value-of select="@scale"/></sup></xsl:if><xsl:value-of select="@kind"/>)
        <sup><xsl:value-of select="@exponent"/></sup>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and not(@exponent!='1')]" mode="unitFormula">
          (<xsl:if test="@multiplier!='1'"><xsl:value-of select="@multiplier"/>&#8901;</xsl:if><xsl:if test="@scale!='0'">10<sup><xsl:value-of select="@scale"/></sup></xsl:if><xsl:value-of select="@kind"/>)
    </xsl:template>

    <xsl:template match="l2v1:listOfUnits" mode="unitFormula">
      <span class="error">= not supported for l2v1 =</span>
    </xsl:template>
<!-- END OF unitFormula/unitFormulaScale mode -->

<!-- BEGIN OF idOrName mode -->
  <xsl:template match="@id" mode="idOrName">
      <xsl:if test="$useNames='true' and count(./../@name)>0">[<xsl:value-of select="./../@name"/>]</xsl:if>  <!-- for simbio only-->
      <xsl:if test="$useNames='true' and count(./../@name)=0">[no name]</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
  </xsl:template>
<!-- END OF idOrName mode -->

<!-- BEGIN OF reactionFormula mode -->
  <xsl:template match="*[local-name()='reaction']" mode="reactionFormula">
    <xsl:if test="count(*[local-name()='listOfReactants']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfReactants']" mode="reactionFormula"/>
    <xsl:if test="@reversible='false' and @fast='true'"> &#8594; </xsl:if>
    <xsl:if test="not(@reversible='false') and @fast='true'"> &#8596; </xsl:if>
    <xsl:if test="@reversible='false' and not(@fast='true')"> &#8658; </xsl:if>
    <xsl:if test="not(@reversible='false') and not(@fast='true')"> &#8660; </xsl:if>
    <xsl:if test="count(*[local-name()='listOfProducts']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfProducts']" mode="reactionFormula"/>
  </xsl:template>

  <!-- listOfReactants / listOfProducts-->
  <xsl:template match="*[local-name()='listOfReactants']
    | *[local-name()='listOfProducts']" mode="reactionFormula">
    <xsl:for-each select="*[local-name()='speciesReference']">
      <xsl:if test="@stoichiometry!='1'"><xsl:value-of select="@stoichiometry"/>&#215;</xsl:if>
	  <xsl:apply-templates select="@species"/>
      <xsl:if test="position()!=last()"> + </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- listOfModifiers-->
  <xsl:template match="*[local-name()='listOfModifiers']" mode="reactionFormula">
    <xsl:for-each select="*[local-name()='modifierSpeciesReference']">
	  <xsl:apply-templates select="@species"/>
      <xsl:if test="position()!=last()">; </xsl:if>
    </xsl:for-each>
  </xsl:template>
<!-- END OF reactionFormula mode -->

<!-- BEGIN OF mml: part, =TO DO= include $correctMathml switcher, correction of SimBiology specific functions -->
  <!-- correct for max function -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='max'][following-sibling::mml:ci]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="max" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- exclude vertcat inside max -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='max'][following-sibling::mml:apply]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="max" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[2]/*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- correct for min function -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='min'][following-sibling::mml:ci]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="min" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- exclude vertcat inside min -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='min'][following-sibling::mml:apply]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="min" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[2]/*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- use id or names for equations and normalize space -->
  <xsl:template match="mml:ci">
    <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:if test="$useNames='true' and key('idKey',normalize-space(text()))/@name">[<xsl:value-of select="key('idKey',normalize-space(text()))/@name"/>]</xsl:if>
      <xsl:if test="$useNames='true' and not(key('idKey',normalize-space(text()))/@name)">[no name]</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="normalize-space(text())"/></xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- adaptation of e-notation for MathJax -->
  <xsl:template match="mml:cn[@type='e-notation']">
    <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="normalize-space(text()[1])"/><xsl:if test="normalize-space(text()[2])!='0'">e<xsl:copy-of select="normalize-space(text()[2])"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- adaptation of integer for MathJax -->
  <xsl:template match="mml:cn[@type='integer']">
    <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="normalize-space(text())"/>
    </xsl:element>
  </xsl:template>

  <!-- just copy mml or not -->
  <xsl:template match="mml:math">
    <xsl:if test="$equationsOff='true'"><span class="sv-hidden">Equations are hidden</span></xsl:if>
    <xsl:if test="not($equationsOff='true')">
      <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mml:*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mml:lambda">
   <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
    <xsl:element name="equivalent" namespace="http://www.w3.org/1998/Math/MathML"/>
    <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">f</xsl:element>
      <xsl:copy-of select="mml:bvar/mml:*"/>
    </xsl:element>
    <xsl:copy-of select="*[local-name()!='bvar']"/>

   </xsl:element>
  </xsl:template>
<!-- END OF mml: part -->
</xsl:stylesheet>
