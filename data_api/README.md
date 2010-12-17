*2010-05-21*

# kooaba Data API

The kooaba data API provides the ability to manage content in kooaba's image recognition system.
It is implemented as a RESTful web service using XML data over HTTP and allows to add and remove
images, as well as their associated meta data.

## Data Model

The recognition system is organized into groups, items, images and resources. API users are member
of one or more groups, which they can add data to.

When adding data to the system, you start with an item. An item represents the physical object you 
want to make recognizable. It is a container for images which identify the object. When the item
has been created, you can create associated images. You can also store a reference-id in the item,
while creating it. This reference-id can then be used to get the item later.

## Authentication

Authentication is managed using our custom KWS HTTP authentication scheme. Every request must include
the Authorization HTTP header. See our separate document on how to construct the KWS header value.

## Requests

There are two basic types of requests, read requests and write requests. Read requests are HTTP GET
requests which return XML-encoded data representations of the requested resources. Write requests
allow to create new resources (POST), update existing resources (PUT) or delete resources (DELETE).

### Access Control

When trying to access resources which do not belong to the user, an empty response with status code
403 Forbidden is returned.

When trying to perform write operations on read-only resources, an empty response with status code
405 Method Not Allowed is returned.

## Resources

### Groups

Group resources are read-only.

---

#### Show

Returns an existing group.

**Request**

`GET /api/groups/#{id}.xml`

**Response**

    Status: 200 OK

    <group>
      <id type="integer">6</id>
      <title>API Group</title>
      <items-count type="integer">2</items-count>
    </group>

---

#### Index

Returns a list of groups the API user is a member of.

**Request**

`GET /api/groups.xml`

**Response**
    
    Status: 200 OK

    <groups type="array">
      <group>
        ...
      </group>
    </groups>


### Items

Item resources have read and write permissions.

---

#### Show

Returns an existing item.

**Request**

`GET /api/items/#{id}.xml`

**Response**

    Status: 200 OK

    <item>
      <id type="integer">70</id>
      <title>Item Title from API</title>
      <group-id type="integer">6</group-id>
      <created-at type="datetime">2010-02-11T09:45:23+01:00</created-at>
      <updated-at type="datetime">2010-02-11T09:45:23+01:00</updated-at>
      <images type="array">
        <image>
          <id type="integer">163</id>
          <file-name>upload.jpeg</file-name>
          <file-size type="integer">134422</file-size>
          <file-type>image/jpeg</file-type>
          <status>INACTIVE</status>
          <item-id type="integer">71</item-id>
          <created-at type="datetime">2010-02-11T09:47:47+01:00</created-at>
          <updated-at type="datetime">2010-02-11T09:47:47+01:00</updated-at>
        </image>
      </images>
    </item>

---

#### Index

Returns a list of items belonging to a given group

**Request**

`GET /api/groups/#{group_id}/items.xml`

**Response**

    Status: 200 OK

    <items type="array">
      <item>
        ...
      </item>
      <item>
         ...
      </item>
    </items>

---

Returns a list of items belonging to a given group and having the attribute values specified in xml

**Request**

`GET /api/groups/#{group_id}/items.xml?item[title]=MyTitle`
 params can be item[title] or item[reference_id]
 
**Response**

    Status: 200 OK

    <items type="array">
      <item>
        <title>MyTitle</title>
        ...
      </item>
      <item>
        <title>MyTitle</title>
        ...
      </item>
    </items>

---

#### New

Returns a blank XML template that may be used as a guide for populating the fields of a new Item record.

**Request**

`GET /api/groups/#{group_id}/items/new.xml`

**Response**

    Status: 200 OK

    <item>
      ...
    </item>


---

#### Create

Creates a new item belonging to a given group.

**Request**

`POST /api/groups/#{group_id}/items.xml`

    Content-Type: application/xml

    <item>
      <title>Item Title from API</title>
      <reference-id>My reference id</reference-id>
    </item>
    
**Response**

    Status: 201 Created
    Location: http://my.kooaba.com/api/items/#{new-item-id}.xml

    <item>
      <id type="integer">78</id>
      <title>Item Title from API</title>
      <reference-id>My reference id</reference-id>
      <group-id type="integer">6</group-id>
      <created-at type="datetime">2010-02-11T15:17:50+01:00</created-at>
      <updated-at type="datetime">2010-02-11T15:17:50+01:00</updated-at>
      <images type="array"/>
    </item>

---

#### Update

Updates information about the given item.

**Request**

`PUT /api/items/#{id}.xml`
    
    Content-Type: application/xml

    <item>
      <title>Updated Title from API</title>
    </item>

**Response**

    Status: 200 OK

---

#### Destroy

Destroys the given item and all of its associated images.

**Request**

`DELETE /api/items/#{id}.xml`

**Response**

    Status: 200 OK

### Images

Image resources have read and write permissions. In order to create images, image files must be uploaded first
in order to be attached to an image resource.

---

#### Show

Returns an existing image.

**Request**

`GET /api/images/#{id}.xml`

**Response**

    Status: 200 OK

    <image>
      <id type="integer">2592</id>
      <item-id type="integer">4067</item-id>
      <external-id type="integer" nil="true"></external-id>
      <file-name>upload.jpeg</file-name>
      <file-sha1>94cc5d8169302127fe8b058d1108cee29df3bebb</file-sha1>
      <file-size type="integer">134422</file-size>
      <file-type>image/jpeg</file-type>
      <status>INACTIVE</status>
    </image>

---

#### Index

Returns a list of images belonging to a given item.

**Request**

`GET /api/items/#{item_id}/images.xml`

**Response**

    Status: 200 OK

    <images type="array">
      <image>
        ...
      </image>
      <image>
        ...
      </image>
    </images>

---

#### Create

Creates a new image belonging to a given item using a previously uploaded file.

**Request**

`POST /api/items/#{item_id}/images.xml`

    Content-Type: application/xml

    <image>
      <file>
        <upload-id>94cc5d8.96</upload-id>
      </file>
    </image>

**Response**

    Status: 201 Created
    Location: http://my.kooaba.com/api/images/#{new-image-id}.xml

    <image>
      <id type="integer">2600</id>
      <item-id type="integer">4076</item-id>
      <external-id type="integer" nil="true"></external-id>
      <file-name>upload.jpeg</file-name>
      <file-sha1>94cc5d8169302127fe8b058d1108cee29df3bebb</file-sha1>
      <file-size type="integer">134422</file-size>
      <file-type>image/jpeg</file-type>
      <status>INACTIVE</status>
      <created-at type="datetime">2010-02-12T15:57:20+01:00</created-at>
      <updated-at type="datetime">2010-02-12T15:57:20+01:00</updated-at>
    </image>

---

#### Destroy

Destroys the given image.

**Request**

`DELETE /api/images/#{id}.xml`

**Response**

    Status: 200 OK

---

#### Status Update

Changes the status of the given image. The value of the status name must be ‘ACTIVE’ or ‘INACTIVE’. Note that changing the status of an image might fail if the image is in the process of being activated.

**Request**

`PUT /api/images/#{id}/status.xml`

    Content-Type: application/xml

    <status>
      <name>ACTIVE</name>
    </status>

**Response** (when the image could be activated right away)

    Status: 200 OK

    <image>
      <id type="integer">2592</id>
      ...
      <status>ACTIVE</status>
    </image>

**Response** (when the image the activation has not been completed)

    Status: 202 Accepted

    <image>
      <id type="integer">2592</id>
      ...
      <status>ACTIVATION_QUEUED</status>
    </image>

**Response** (when the image cannot be activated due to errors)

    Status: 422 Unprocessable Entity
    
    <errors>
      <error>Status cannot be set to ACTIVE because no recognition server is configured.</error>
    </errors>

### Uploads

Some operations, like creating images, allow or require you to attach a file to the record. To do this via the API, you need to send a POST request to the "/api/uploads.xml" URI. The body of the request should be the content of the file you want to attach:

**Request**

`POST /api/uploads.xml`

    Content-Type: image/jpeg
    
    [BINARY DATA]

If the upload succeeds, you'll get an XML response back, telling you the ID of your upload. (Your upload is not yet associated with any record, and if you do not do anything with it, it will be deleted within the next hour.)

**Response**

    Status: 200 OK

    <upload>
      <id>94cc5d8.2</id>
    </upload>

