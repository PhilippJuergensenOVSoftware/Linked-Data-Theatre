<!--

    NAME     header.xpl
    VERSION  1.18.0
    DATE     2017-06-18

    Copyright 2012-2017

    This file is part of the Linked Data Theatre.

    The Linked Data Theatre is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The Linked Data Theatre is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the Linked Data Theatre.  If not, see <http://www.gnu.org/licenses/>.

-->
<!--
    DESCRIPTION
    Debug option to show header information
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
		  xmlns:xforms="http://www.w3.org/2002/xforms"
          xmlns:oxf="http://www.orbeon.com/oxf/processors"
		  xmlns:sparql="http://www.w3.org/2005/sparql-results#"
		  xmlns:ev="http://www.w3.org/2001/xml-events"
		  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		  xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<!-- Configuration> -->
	<p:param type="input" name="instance"/>

	<!-- Header information needed for Cool-URI implementation -->
	<p:processor name="oxf:request">
	  <p:input name="config">
		<config stream-type="xs:anyURI">
		  <include>/request</include>
		</config>
	  </p:input>
	  <p:output name="data" id="request"/>
	</p:processor>

	<!-- Get credentials and user roles -->
	<p:processor name="oxf:request-security">
		<p:input name="config" transform="oxf:xslt" href="#instance">        
			<config xsl:version="2.0">
				<xsl:for-each select="theatre/roles/role">
					<role><xsl:value-of select="."/></role>
				</xsl:for-each>
			</config>    
		</p:input>
		<p:output name="data" id="roles"/>
	</p:processor>

	<p:choose href="#instance">
		<!-- Only show header information in development-mode -->
		<p:when test="theatre/@env='dev'">
			<!-- Transform header to html page -->
			<p:processor name="oxf:xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config" href="../transformations/header2html.xsl"/>
				<p:output name="data" id="html"/>
			</p:processor>
			<!-- Convert XML result to HTML -->
			<p:processor name="oxf:html-converter">
				<p:input name="config">
					<config>
						<encoding>utf-8</encoding>
						<version>5.0</version>
					</config>
				</p:input>
				<p:input name="data" href="#html" />
				<p:output name="data" id="converted" />
			</p:processor>
			<!-- Serialize -->
			<p:processor name="oxf:http-serializer">
				<p:input name="config">
					<config>
						<cache-control><use-local-cache>false</use-local-cache></cache-control>
					</config>
				</p:input>
				<p:input name="data" href="#converted"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:http-serializer">
				<p:input name="config">
					<config>
						<cache-control><use-local-cache>false</use-local-cache></cache-control>
						<status-code>404</status-code>
					</config>
				</p:input>
				<p:input name="data">
					<document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" content-type="text/plain"/>
				</p:input>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
</p:config>
