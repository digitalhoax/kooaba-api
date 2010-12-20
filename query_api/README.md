# kooaba Query API
Query API Version 1.1 (2010-12-20)

## Introduction
This document specifies the API (Application Programming Interface) for the kooaba Query API. The API allows for recognizing rigid objects in digital images via a web-service. The content of this document covers the technical specifications concerning the communication via HTTP (Hypertext Transfer Protocol) to the kooaba recognition server. Many parts of the kooaba web services - like the authentication mechanism - are inspired by the [Amazon Web Services](http://docs.amazonwebservices.com/AmazonS3/latest/). 

If this documentation leaves you with any open questions, we suggest you consult our [Google Group](http://groups.google.com/group/kooaba-api) for the API and potentially open a discussion there.

## Functionality Overview
The query image is sent via this API to our recognition server, where it is analyzed and compared against a pre-defined database of reference images. The content associated with matching reference images is sent back, if the recognition was successful.

### Terminology
The following terms define the components you will encounter while using the API.

#### Items
An item is the basic unit we use in the reference database, and represents a rigid object consisting of one ore more reference images and metadata.

#### Groups
A group is a container for items in the image recognition system. Typically a container contains a set of items of the same type (e.g. Books or CDs), or all the items of a particular Data API user. Thus, each Query API user is usually member of at least one group. A group is defined by a group id. (Please contact kooaba support, if you don't know the group id's for your service).

#### Queries
A query consists of an image and a list of groups to search the image in.

#### Request Limits
Per default the number of requests that can be made to the API within a 24-hour period is limited. The default limit is 50. Please contact us if you require higher limits.


## Using the API

The API is accessed by passing request parameters encapsulated in a HTPP post requests. The URL for the POST request defines the action that is called. The response is returned in form of XML. The API allows to call the following actions:

__Groups__        : List available groups  
__Create Query__  : Make a query to the API

All requests to the API have to be authenticated. Thus, we start with a description of authentication, before describing the individual actions.

- - - 

## Authentication

The kooaba REST API uses a custom HTTP scheme. A request is authenticated as follows. First, selected elements of the request are concatenated to form a string. Then a KWS Secret Key (see definition below) is used to calculate a hash code of that string. This process is called "signing the request", and we call the output of hash code computation the "signature" because it simulates the security properties of a real signature. Finally, the signature is added as a parameter of the request, using the syntax described in this section.

### Definitions

#### KWS Access Key
Individual hexadecimal access key for each user provided by kooaba upon registration. Example: _df8d23140eb443505c0661c5b58294ef472baf64_


#### KWS Secret Key
Hexadecimal secret key to construct the signature together with the KWS Access key and some other selected elements of the request. Example: _054a431c8cd9c3cf819f3bc7aba592cc84c09ff7_

#### HTTP-Verb
The HTTP method used for the action. Example: _GET, POST_, etc.

#### Content-MD5
The hexadecimal MD5 hash (lowercase!) of the whole request body (from first boundary to last one, including the boundary itself). Use an empty string for request types without request body (GET, DELETE).

#### Content-Type
If using POST or PUT, the content-type of the request body (like _multipart/form-data_), for other types use an empty string.

#### Date
Current date, defined by [RFC 2616](http://www.ietf.org/rfc/rfc2616.txt), section 3.3.1. Example: _Sun, 06 Nov 1994 08:49:37 GMT_

### Constructing the Authentication Header

The kooaba REST API uses the standard HTTP Authorization header to pass authentication information. Under the kooaba authentication scheme, the Authorization header has the following form.

    Authorization: KWS {KWSAccessKey}:{Signature}

Developers are issued an KWS Access Key and KWS Secret Key. For request authentication, the KWSAccessKey element identifies the secret key that was used to compute the signature, and (indirectly) the developer making the request.

The Signature element is the SHA1 hash value of the KWS Secret Key combined with selected elements from the request, and so the Signature part of the Authorization header will vary from request to request. If the request signature calculated by the system matches the Signature included with the request, then the requester will have demonstrated possession to the KWS Secret Key. The request will then be processed under the identity, and with the authority, of the developer to whom the key was issued.

Following is pseudo-grammar that illustrates the construction of the Authorization request header (\n means the Unicode code point U+000A).

    Authorization = "KWS" + " " + KWSAccessKey + ":" + Signature;

    Signature = Base64(SHA1-Raw-Digest( StringToSign ) ) );

    StringToSign = KWSSecretKey + "\n\n" +

      HTTP-Verb + "\n" +

      Content-MD5 + "\n" +

      Content-Type + "\n" +

      Date + "\n" +

      Request-Path;

### Time Stamp Requirement

A valid time-stamp (using the HTTP Date header) is mandatory for authenticated requests. Furthermore, the client time-stamp included with an authenticated request must be within 15 minutes of the kooaba system time when the request is received. If not, the request will fail with the "Request Time Too Skewed" error status code.

- - - 

## Action: List Groups

Lists all the groups associated to the API user. Image queries can then be performed in one or more groups simultaneously.

### Making the call

_Verb_         : GET

_URL_           : http://search.kooaba.com/groups.xml

_Authorization_ : _See above_

### Sample Response

HTTP status code 200 (OK)


    <?xml version="1.0" encoding="UTF-8"?>
    <groups type="array">
      <group>
        <id type="integer">32</id>
        <title>Sample Group 1</title>
      </group>
      <group>
        <id type="integer">34</id>
        <title>Sample Group 2</title>
      </group>
    </groups>
    
- - - 

## Action: Create Query

This is the main action of the query API. Creating a new query is done by sending a multipart POST request with image and a set of optional parameters.

### Making the call
_Verb_ : POST

_URL_  : http://search.kooaba.com/queries.xml

### Request Headers

_Content-Type_ : This must be set to `multipart/form-data`

_Date_         : Current date, defined by RFC 2616

_Authorization_  : _See above_


### Request Body

The request body needs to be composed as multipart MIME data as defined in [RFC 2388](http://www.ietf.org/rfc/rfc2388.txt). Parameters to the action are passed as parts of the multipart data. The _Create Query_ action has one required part (Image) and needs to be composed of at least two parts. In addition, a set of optional parameters can be specified in the request body.

#### Image part (required)
Specifies the query image to be sent to the service (in JPEG or PNG format). We recommend downscaling images to at most 640 pixels (at the larger side). Using query images smaller than 320 pixels is not recommended.

##### Headers:
_Content-Type_              : `image/jpeg` or `image/png`

_Content-Disposition_       :  `form-data; name="query[file]"`

_Content-Transfer-Encoding_ : _binary_

##### Content:
_[Binary Data]_

#### Group part (required)
Specifies the group to search in. To search in multiple groups at once, you can add multiple group parts to the multipart body (one for each group).

##### Headers:
__Content-Disposition__ : `form-data; name="query[group_ids][]"`

##### Content 
(type=integer), example: `32`

#### Multiple items part (optional) 
Some requests may return multiple matches, i.e. multiple reference images that match the query. This parameter allows for retrieving these multiple matches. When multiple items are returned, the response will also include a ``matches'' parameter, which indicates a score for each of the matches.

##### Headers:
_Content-Disposition_     : `form-data; name="query[multiple_items]"`

##### Content:
(type=boolean, either `true` or `false`, default is `false`), example: `true`


#### Location Parts (optional)
The location parts allows for specifying GPS coordinates for a request, as for instance obtained from a mobile client device. The location is set with two parts, latitude and longitude, which follow the exact same structure.

##### Headers (Latitude):
__Content-Disposition__     : _form-data; name="query[latitude]"

##### Content (Latitude):
(type=double), example:37.33168900

##### Headers (Longitude):
__Content-Disposition__     : _form-data; name="query[longitude]"

##### Content (Longitude):
(type=double), example: -122.03073100

#### Bounding Box part (optional)
This parameter allows for retrieving the area in the query image that matched the database image. The area is defined by a bounding box with four corners.
 
##### Headers:
__Content-Disposition__ : _form-data; name="query[bounding_box]" 

##### Content 
(type=boolean, either "true" or "false", default is "false"), example: true

#### Country part (optional)
Allows for filtering results for items that are associated with a country (applies mainly to media covers like books, CD's , etc.)

##### Headers:  
__Content-Disposition__ : _form-data; name="query[country]"

##### Content:  
(type=string, ISO 3166-1 Alpha-2 country code), 
example: US If no matching item resource is found, all item resources are returned in order to minimize network traffic. 

#### Language part (optional) 
Allows for filtering for items that are associated with a language (applies mainly to media covers like books, CD's , etc.)

##### Headers:  
__Content-Disposition__ : _form-data; name="query[language]" 

##### Content:  
(type=string, IETF language tag), example: en

- - -

### Sample Request with Image and Group parts

Note that the HTTP library you use will add addition headers (like _Accept_ and _Host_).


    Content-Type: multipart/form-data; boundary=49182cdfb857c
    Host: search.kooaba.com
    Date: Mon, 10 Nov 2008 12:45:19 GMT
    Authorization: KWS df8d23140eb443505c0661c5b58294ef472baf64:jHX6oLeqTXpynyqcvVC2MSHarhU=
    Content-Length: 85402

    --49182cdfb857c 
    Content-Disposition: form-data; name="query[group_ids][]" 

    32 
    --49182cdfb857c 
    Content-Disposition: form-data; name="query[file]"; filename="lena.jpg" 
    Content-Transfer-Encoding: binary 
    Content-Type: image/jpeg 

    [BINARY DATA]
    --49182cdfb857c-- 

### Sample Request with Multiple Items part


    Date: Sat, 09 May 2009 16:50:30 GMT
    Content-Type: multipart/form-data; boundary=985206851141787760
    Authorization: KWS df8d23140eb443505c0661c5b58294ef472baf64:q6RUy13K8efmAYwcfqTtKJGIlqE=

    --118221163862253392190 
    Content-Disposition: form-data; name="query[multiple_items]" 

    true 
    --118221163862253392190 
    Content-Disposition: form-data; name="query[file]"; filename="in.jpg" 
    Content-Transfer-Encoding: binary 
    Content-Type: image/jpeg 

    [BINARY DATA] 
    --118221163862253392190-- 
    
### Sample Request with Country part and multiple Group parts

    Date: Sat, 09 May 2009 16:50:30 GMT
    Content-Type: multipart/form-data; boundary=985206851141787760
    Authorization: KWS df8d23140eb443505c0661c5b58294ef472baf64:q6RUy13K8efmAYwcfqTtKJGIlqE=

    --118221163862253392190 
    Content-Disposition: form-data; name="query[country]" 

    UK 
    --118221163862253392190 
    Content-Disposition: form-data; name="query[group_ids][]" 

    1 
    --118221163862253392190 
    Content-Disposition: form-data; name="query[group_ids][]" 

    4 
    --118221163862253392190 
    Content-Disposition: form-data; name="query[file]"; filename="in.jpg" 
    Content-Transfer-Encoding: binary 
    Content-Type: image/jpeg 

    [BINARY DATA] 
    --118221163862253392190-- 

- - -    

## Responses
All responses are returned as XML as a direct response to the HTTP Post request. 

### XML Format of responses
The following XML tags may appear in the response:

    <item>
    
This is the main element of a successful recognition and contains information about recognized items. If nothing is recognized the value of this element is nil. The item contains further child-elements such as title etc. The item may contain an attribute ``medium-type'' which declares the kind of item (e.g. CD, DVD, Book, ...).

    <item><title>
    
The title is a human readable string for each item.

    <item><resources>
    
The item resources are additional meta-data which are associated with the item. These may include URLs, files, etc. (See examples below.)

    <item><reference-id>

If you are also using our Data Upload API, while uploading data, you can specify a reference id (usually your internal id) for each item. This id is returned when querying in the field reference-id.

    <uuid>

This is a [Universal Unique Identifier](http://en.wikipedia.org/wiki/Universally_unique_identifier) for the query. 

    <response>

The response element is for kooaba internal use only at this time. Thus it will usually be nil.
    
    <errors>

If there was a problem with your request, error descriptions are returned within the element errors. (The error codes are returned as HTTP status codes.)

### Example Responses

#### Response with recognized image

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>4lkvlolbp727epnjg02kbm7occ</uuid>
      <group-id type="integer"></group-id>
      <item>
        <title>Lena</title>
      </item>
      <response nil="true"/>
    </query>

#### Example Response with recognized image and reference id

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>5q7l5etqu127fbnqo02kbm7occ</uuid>
      <group-id nil="true"/>
      <result-url>http://my.kooaba.com/q/5q7l5etqu127fbnqo02kbm7occ</result-url>
      <item medium-type="PeriodicalPage">
        <title>Sample Title</title>
        <reference-id>1234</reference-id>
      </item>
      <response nil="true"/>
    </query>

#### Example Response with multiple items returned

Note that when multiple items are returned, the <item> elements contain a "matches" attribute (higher number == better match).

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>5g21bqcf5m27f97vo04cpcoifm</uuid>
      <group-id nil="true"/>
      <items type="array">
        <item medium-type="Dvd" matches="999">
          <title>Cloverfield (2008)</title>
          <item-resources type="array">
            <item-resource>
              <address>0097361390840</address>
              <locale>US</locale>
              <scheme>urn:ean</scheme>
              <title>Cloverfield</title>
            </item-resource>
            <item-resource>
              <address>0724354237126</address>
              <locale>US</locale>
              <scheme>urn:ean</scheme>
              <title>Cloverfield [Blu-ray]</title>
            </item-resource>
          </item-resources>
        </item>
        <item medium-type="Dvd" matches="50">
          <title>Cloverfield</title>
          <item-resources type="array">
            <item-resource>
              <address>3333973153952</address>
              <locale>FR</locale>
              <scheme>urn:ean</scheme>
              <title>Cloverfield</title>
            </item-resource>
          </item-resources>
        </item>
      </items>
      <response nil="true"/>
    </query>

#### Example Response with no match

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>4uqhf7lai327erfe803r10osnd</uuid>
      <group-id type="integer">2</group-id>
      <item nil="true"/>
      <response nil="true"/>
    </query>

#### Example Response with matching country
Note that in this case, the country parameter was matched and is included as element attribute in <item-resources>.

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>5g21bqcf5m27f97vo04cpcoifm</uuid>
      <group-ids type="array">
        <group-id type="integer">1</group-id>
        <group-id type="integer">4</group-id>
      </group-ids>
      <result-url>http://search.kooaba.com/q/5g21bqcf5m27f97vo04cpcoifm</result-url>
      <item medium-type="Dvd">
        <title>Taxi Driver</title>
        <item-resources type="array" country="UK">
          <item-resource>
            <address>5014756039714</address>
            <locale>UK</locale>
            <scheme>urn:ean</scheme>
            <title>Taxi Driver [1976]</title>
          </item-resource>
        </item-resources>
      </item>
      <response nil="true"/>
    </query>


If no item resource matches the country parameter, all resources are returned and there is no country attribute in the <item-resources> element:


    ...
    <item medium-type="Dvd">
      <title>Taxi Driver</title>
      <item-resources type="array">
        <item-resource>
          <address>9780800130183</address>
          <locale>US</locale>
          <scheme>urn:ean</scheme>
          <title>Taxi Driver</title>
        </item-resource>
        <item-resource>
          <address>9780800130923</address>
          <locale>US</locale>
          <scheme>urn:ean</scheme>
          <title>Taxi Driver</title>
        </item-resource>
      ...

- - - 

## Error Messages

What follows is a description of the Error messages that you may encounter while interacting with our system:

### Error message when reached maximum number of requests within a certain time period
This error occurs, when you exceeded your limit of requests. Please contact support in order to increase limits.

HTTP status code 403 (Forbidden)

    <?xml version="1.0" encoding="UTF-8"?>
    <errors>
      <error>You have reached maximum number of requests in a 24-hr period.</error>
    </errors>

### Error message when using group id for group without permission
This error occurs when you try to send queries to a group, to which your user has no access.

HTTP status code 422 (Unprocessable Entity)

    <?xml version="1.0" encoding="UTF-8"?>
    <errors>
      <error>Group - Permission denied for Group with ID=1</error>
    </errors>

### Error message when using inexistent group id
This error occurs when you try to send queries to a group which does not exist.

HTTP status code 422 (Unprocessable Entity)

    <?xml version="1.0" encoding="UTF-8"?>
    <errors>
      <error>Group - Couldn't find Group with ID=1456</error>
    </errors>
