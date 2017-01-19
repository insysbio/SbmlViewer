<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Copyright 2016-2017 Institute for Systems Biology Moscow

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
Description: Creating representation of single element with dependences
modes:
  - reactionFormula
  - dependences
  - searchDependences
  - idOrName/idOrNamePlus

Author: Evgeny Metelkin
Copyright: Institute for Systems Biology, Moscow
Last modification: 2017-01-15

Project-page: http://sbmlviewer.insilicobio.ru
-->
<xsl:stylesheet version="1.0" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:l2v1="http://www.sbml.org/sbml/level2/version1"
  xmlns:l2v2="http://www.sbml.org/sbml/level2/version2"
  xmlns:l2v3="http://www.sbml.org/sbml/level2/version3"
  xmlns:l2v4="http://www.sbml.org/sbml/level2/version4"
  xmlns:l2v5="http://www.sbml.org/sbml/level2/version5"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="xhtml exsl l1v1 l1v2 l1v3 l1v4 l1v5">
  
  <!-- IMPORTS 
  <xsl:include href="sbmlshared.xsl"/> -->
  
  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>
  
  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->
  <xsl:param name="equationsOff">false</xsl:param> <!-- do not show equations -->
  <xsl:param name="input_root" select="/"/> <!-- main document reference -->
  <xsl:param name="elementId">default</xsl:param> <!-- include unitDefinitions and attribute -->
  <xsl:param name="dependent" > 
    <ci><xsl:value-of select="$elementId"/></ci>
    <xsl:apply-templates select="key('idKey', $elementId)" mode="searchDependences"/>
  </xsl:param>

  <!-- top element -->
  <xsl:template match="/">
    <div class="w3-container">
    <xsl:apply-templates select="key('idKey', $elementId)"/>
    </div>
  </xsl:template>
  
  <!-- compartment summary -->
  <xsl:template match="*[local-name()='compartment']">
    <h1>compartment</h1>
    <h3>id: <xsl:value-of select="@id"/></h3>
    <h3>name: <xsl:value-of select="@name"/></h3>
    <p><xsl:apply-templates select="*[local-name()='notes']"/></p>
    <!--<p>size: <xsl:value-of select="@size"/></p>-->
    <!--<p>outside: <xsl:value-of select="@outside"/></p>-->
    <xsl:call-template name="dependences"/>
  </xsl:template>
  
  <!-- parameter summary -->
  <xsl:template match="*[local-name()='parameter']">
    <h1>parameter</h1>
    <h3>id: <xsl:value-of select="@id"/></h3>
    <h3>name: <xsl:value-of select="@name"/></h3>
    <p><xsl:apply-templates select="*[local-name()='notes']"/></p>
    <!--<p>size: <xsl:value-of select="@size"/></p>-->
    <!--<p>outside: <xsl:value-of select="@outside"/></p>-->
    <xsl:call-template name="dependences"/>
  </xsl:template>
  
  <!-- species summary -->
  <xsl:template match="*[local-name()='species']">
    <h1>species</h1>
    <h3>id: <xsl:value-of select="@id"/></h3>
    <h3>name: <xsl:value-of select="@name"/></h3>
    <p ><xsl:apply-templates select="*[local-name()='notes']"/></p>
    <p>compartment: <xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></p>
    <!--<p>initialConcentration: <xsl:value-of select="@initialConcentration"/></p>-->
    <!--<p>boundaryCondition: <xsl:value-of select="@boundaryCondition"/></p>-->
    <xsl:call-template name="dependences"/>
  </xsl:template>
  
  <!-- reaction summary -->
  <xsl:template match="*[local-name()='reaction']">
    <h1>reaction</h1>
    <h3>id: <xsl:value-of select="@id"/></h3>
    <h3>name: <xsl:value-of select="@name"/></h3>
    <p ><xsl:apply-templates select="*[local-name()='notes']"/></p>
    <!--<p>reversible: <xsl:value-of select="@reversible"/></p>-->
    <!--<p>fast: <xsl:value-of select="@fast"/></p>-->
    <h3>formula: </h3>
    <p class="w3-xlarge"><xsl:apply-templates select="." mode="reactionFormula"/></p>
    <!--<p>math: <xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/></p>-->
    <xsl:call-template name="dependences"/>
  </xsl:template>
  
  <!-- Notes type: just copy -->
  <xsl:template match="*[local-name()='notes']">
    <xsl:copy-of select="node()"/>
  </xsl:template>

<!-- BEGIN OF idOrName/idOrNamePlus mode -->
  <xsl:template match="@id|@variable" mode="idOrName">
      <xsl:if test="$useNames='true'"><xsl:value-of select="./../@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
    </xsl:template>
    
    <xsl:template match="@id|@variable" mode="idOrNamePlus">
      <xsl:if test="$useNames='true'"><xsl:value-of select="./../@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
       <div style="
         position:absolute; left:50%; bottom:90%; border-radius:6px; padding:8px; width:300px;
         " class="w3-text w3-pale-blue">
           <xsl:apply-templates select="../*[local-name()='notes']" />
         </div>
    </xsl:template>
<!-- END OF idOrName/idOrNamePlus mode -->
  
<!-- BEGIN OF reactionFormula mode -->
  <xsl:template match="
    *[local-name()='reaction']
    " mode="reactionFormula">
    <xsl:if test="count(*[local-name()='listOfReactants']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfReactants']" mode="reactionFormula"/>
    <xsl:if test="@reversible='false' and @fast='true'"> &#8594; </xsl:if>
    <xsl:if test="not(@reversible='false') and @fast='true'"> &#8596; </xsl:if>
    <xsl:if test="@reversible='false' and not(@fast='true')"> &#8658; </xsl:if>
    <xsl:if test="not(@reversible='false') and not(@fast='true')"> &#8660; </xsl:if>
    <xsl:if test="count(*[local-name()='listOfProducts']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfProducts']" mode="reactionFormula"/>
    <xsl:apply-templates select="*[local-name()='listOfModifiers']" mode="reactionFormula"/>
  </xsl:template>
  
  <!-- listOfReactants / listOfProducts-->
  <xsl:template match="
    *[local-name()='listOfReactants'] |
    *[local-name()='listOfProducts']
    " mode="reactionFormula">
    <xsl:for-each select="*[local-name()='speciesReference']">
      <xsl:if test="@stoichiometry!='1'">
        <xsl:value-of select="@stoichiometry"/> &#215;
      </xsl:if>
      <xsl:apply-templates select="key('idKey',@species)/@id" mode="idOrName"/>
      <xsl:if test="position()!=last()">+</xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!-- listOfModifiers-->
  <xsl:template match="
    *[local-name()='listOfModifiers'] 
    " mode="reactionFormula">
    <xsl:if test="count(*[local-name()='modifierSpeciesReference'])>0"> ~ </xsl:if>
    <xsl:for-each select="*[local-name()='modifierSpeciesReference']">
      <xsl:apply-templates select="key('idKey',@species)/@id" mode="idOrName"/>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:for-each>
  </xsl:template>
<!-- END OF reactionFormula mode -->
  
<!-- BEGIN OF searchDependences mode -->  
  <xsl:template match="*[local-name()='reaction']" mode="searchDependences">
    <xsl:for-each select="descendant::mml:ci">
      <ci>
      <xsl:value-of select="normalize-space(text())"/>
      </ci>
      <xsl:apply-templates select="key('idKey', normalize-space(text()))" mode="searchDependences"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="*[local-name()='compartment' or local-name()='parameter' or local-name()='species']" mode="searchDependences">
    <xsl:for-each select="key('variableKey', @id)/descendant::mml:ci">
      <ci>
      <xsl:value-of select="normalize-space(text())"/>
      </ci>
      <xsl:apply-templates select="key('idKey', normalize-space(text()))" mode="searchDependences"/>
    </xsl:for-each>
  </xsl:template>
<!-- END OF searchDependences mode --> 
 
<!-- BEGIN OF dependences mode -->
  <xsl:template name="dependences">
    <h3>dependences:</h3>
    <table>
      <xsl:for-each select="exsl:node-set($dependent)/xhtml:ci[not(text()=preceding-sibling::xhtml:ci/text())]">
       <xsl:apply-templates select="
       exsl:node-set($input_root)/descendant::*[@id=current()/text()]
       " mode="dependences"/>
      </xsl:for-each>
    </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='compartment' or local-name()='parameter']" mode="dependences">
    <tr>
    <td class="w3-tooltip" style="cursor:default;"><xsl:apply-templates select="@id" mode="idOrNamePlus"/></td>
    <td>=</td>
    <td style="width:500px;">
    <xsl:if test="not(key('variableKey', @id))">
      <xsl:value-of select="@value"/>
      <xsl:value-of select="@size"/>
    </xsl:if>
      <xsl:apply-templates select="key('variableKey', @id)/mml:math"/>
    </td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']" mode="dependences">
    <tr>
    <td class="w3-tooltip" style="cursor:default;"><xsl:apply-templates select="@id"  mode="idOrNamePlus"/></td>
    <td>=</td>
    <td style="width:500px;"><xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/></td>
    </tr> 
  </xsl:template>
  
  <xsl:template match="*[local-name()='species']" mode="dependences">
    <tr>
    <td class="w3-tooltip" style="cursor:default;">
    <xsl:apply-templates select="@id"  mode="idOrNamePlus"/>
    <xsl:if test="not(boundaryCondition='true')">(0)</xsl:if>
    </td>
    <td>=</td>
    <td style="width:500px;">
    <xsl:if test="not(key('variableKey', @id))">
      <xsl:value-of select="@initialConcentration"/>
    </xsl:if>
      <xsl:apply-templates select="key('variableKey', @id)/mml:math"/>
    </td>
    </tr>     
  </xsl:template>
<!-- END OF dependences mode -->
  
<!-- BEGIN OF mml: part -->
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
      <xsl:if test="$useNames='true'"><xsl:value-of select="key('idKey',normalize-space(text()))/@name"/></xsl:if>  <!-- for simbio only-->
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
  
  <!-- just copy mml:math or not -->
  <xsl:template match="mml:math">
    <xsl:if test="$equationsOff='true'"><i style="color:red;">Equations are hidden</i></xsl:if>
    <xsl:if test="not($equationsOff='true')">
      <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <!-- just copy all mml elements -->
  <xsl:template match="mml:*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
<!-- END OF mml: part -->
</xsl:stylesheet>
