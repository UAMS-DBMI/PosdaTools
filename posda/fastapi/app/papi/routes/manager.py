import os
import httpx
from contextlib import asynccontextmanager
from fastapi import APIRouter, HTTPException

from .auth import logged_in_user

router = APIRouter(
    tags=["Manager"],
    dependencies=[logged_in_user]
)

WP_USER     = os.environ.get('POSDA_WP_USER', '')
WP_PASSWORD = os.environ.get('POSDA_WP_PASSWORD', '')

WP_ENDPOINT_PATHS = {
    "Media":            "/api/wp/v2/media",
    "Citation":         "/api/v1/citations",
    "Collection":       "/api/v1/collections",
    "Analysis Result":  "/api/v1/analysis-results",
    "Download":         "/api/v1/downloads",
    "Version":          "/api/v1/versions",
    "Version Download": "/api/v1/version_downloads",
    "Cancer Type":      "/api/v1/cancer-types",
    "Location":         "/api/v1/cancer-locations",
    "Species":          "/api/v1/species",
    "Data Type":        "/api/v1/data-types",
    "Supporting Data":  "/api/v1/supporting-data",
    "File Type":        "/api/v1/file-types",
    "License":          "/api/v1/licenses",
    "Requirement":      "/api/v1/download-requirements",
    "Program":          "/api/v1/programs",
}

def wp_url(endpoint: str) -> str:
    return f"{os.environ.get('POSDA_WP_URL', '')}{WP_ENDPOINT_PATHS[endpoint]}"

def wp_edit_url(post_id: int) -> str:
    return f"{os.environ.get('POSDA_WP_URL', '')}/wp-admin/post.php?post={post_id}&action=edit"

def _params(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None, **extra) -> dict:
    p = {"status": status}
    if slug:   p["slug"]    = slug
    if search: p["search"]  = search
    if ids:    p["include"] = ids
    p.update({k: v for k, v in extra.items() if v is not None})
    return p


# ----------------------------
# HTTP helpers
# ----------------------------

@asynccontextmanager
async def wp_client():
    async with httpx.AsyncClient(
        auth=(WP_USER, WP_PASSWORD),
        timeout=30.0
    ) as client:
        yield client

async def wp_get(path: str, params: dict = None):
    async with wp_client() as client:
        r = await client.get(path, params=params)
        if r.status_code == 404:
            return None
        r.raise_for_status()
        return r.json()

async def wp_post(path: str, data: dict):
    async with wp_client() as client:
        r = await client.post(path, json=data)
        r.raise_for_status()
        return r.json()

async def wp_patch(path: str, data: dict):
    async with wp_client() as client:
        r = await client.patch(path, json=data)
        r.raise_for_status()
        return r.json()

async def wp_delete(path: str, params: dict = None):
    async with wp_client() as client:
        r = await client.delete(path, params=params)
        r.raise_for_status()
        return r.json()

async def wp_get_paged(path: str, params: dict = None):
    all_items = []
    page = 1
    base_params = {"per_page": 100, "status": "publish,draft", **(params or {})}
    async with wp_client() as client:
        while True:
            r = await client.get(path, params={**base_params, "page": page})
            r.raise_for_status()
            all_items.extend(r.json())
            if page >= int(r.headers.get("X-WP-TotalPages", 1)):
                break
            page += 1
    return all_items

# Media uses the core WP API — no status filter, paging unreliable past page 1
async def wp_get_media_paged(params: dict = None):
    all_items = []
    page = 1
    base_params = {**(params or {}), "per_page": 100}
    async with wp_client() as client:
        while True:
            r = await client.get(wp_url("Media"), params={**base_params, "page": page})
            r.raise_for_status()
            batch = r.json()
            if not batch:
                break
            all_items.extend(batch)
            total_pages = int(r.headers.get("X-WP-TotalPages", 1))
            if page >= total_pages:
                break
            page += 1
    return all_items


# ----------------------------
# Format helpers
# ----------------------------

def _base(item: dict) -> dict:
    return {
        "id":       item["id"],
        "slug":     item["slug"],
        "type":     item["type"],
        "status":   item["status"],
        "title":    item["title"]["rendered"],
        "view_url": item["link"],
        "edit_url": wp_edit_url(item["id"]),
    }

def format_media(item: dict) -> dict:
    return {
        "id":         item["id"],
        "slug":       item["slug"],
        "type":       item["type"],
        "status":     item["status"],
        "title":      item["title"]["rendered"],
        "media_type": item.get("media_type"),
        "mime_type":  item.get("mime_type"),
        "source_url": item.get("source_url"),
        "view_url":   item["link"],
        "edit_url":   wp_edit_url(item["id"]),
    }

def format_citation(item: dict) -> dict:
    return {
        **_base(item),
        "tcia_citation_type": item.get("tcia_citation_type"),
        "tcia_citation_text": item.get("tcia_citation_text"),
        "tcia_citation_statement": item.get("tcia_citation_statement"),        
        "tcia_citation_doi":  item.get("tcia_citation_doi"),


    }

def format_collection(item: dict) -> dict:
    return {
        **_base(item),
        # Collection Information
        "collection_doi":                          item.get("collection_doi"),
        "collection_page_accessibility":           item.get("collection_page_accessibility"),
        "collection_status":                       item.get("collection_status"),
        "collection_title":                        item.get("collection_title"),
        "collection_short_title":                  item.get("collection_short_title"),
        "collection_browse_title":                 item.get("collection_browse_title"),
        "collection_featured_image":               (item.get("collection_featured_image") or {}).get("ID"),
        "collection_abstract":                     item.get("collection_abstract"),
        "collection_introduction":                 item.get("collection_introduction"),
        "collection_summary_header":               item.get("collection_summary_header"),
        "collection_summary":                      item.get("collection_summary"),
        "collection_acknowledgements":             item.get("collection_acknowledgements"),
        "collection_funding":                      item.get("collection_funding"),
        "hide_from_browse_table":                  item.get("hide_from_browse_table"),
        "program":                                 item.get("program"),
        # Collection Details
        "cancer_types":                            item.get("cancer_types"),
        "cancer_locations":                        item.get("cancer_locations"),
        "species":                                 item.get("species"),
        "subjects":                                item.get("subjects"),
        "data_types":                              item.get("data_types"),
        # Collection Methods
        "subject_inclusion_and_exclusion_criteria": item.get("subject_inclusion_and_exclusion_criteria"),
        "data_acquisition":                        item.get("data_acquisition"),
        "data_analysis":                           item.get("data_analysis"),
        "usage_notes":                             item.get("usage_notes"),
        # Data Access (Current Version)
        "collection_downloads":                    item.get("collection_downloads"),
        "make_new_version":                        item.get("make_new_version"),
        "version_number":                          item.get("version_number"),
        "date_updated":                            item.get("date_updated"),
        "version_change_log":                      item.get("version_change_log"),
        # Data Access Supplemental
        "collection_download_info":                item.get("collection_download_info"),
        "additional_resources":                    item.get("additional_resources"),
        "supporting_data":                         item.get("supporting_data"),
        "related_analysis_results":                item.get("related_analysis_results"),
        "related_collection":                      item.get("related_collection"),
        "analysis_results":                        item.get("analysis_results"),
        "detailed_description":                    item.get("detailed_description"),
        # Citations & Data Usage Policy
        "citations":                               item.get("citations"),
        "publications_related":                    item.get("publications_related"),
        "publications_using":                      item.get("publications_using"),
        # Previous Versions
        "versions":                                item.get("versions"),
    }

def format_analysis_result(item: dict) -> dict:
    return {
        **_base(item),
        # Result Information
        "result_doi":                              item.get("result_doi"),
        "result_page_accessibility":               item.get("result_page_accessibility"),
        "result_title":                            item.get("result_title"),
        "result_short_title":                      item.get("result_short_title"),
        "result_browse_title":                     item.get("result_browse_title"),
        "result_abstract":                         item.get("result_abstract"),
        "result_introduction":                     item.get("result_introduction"),
        "result_summary_header":                   item.get("result_summary_header"),
        "result_summary":                          item.get("result_summary"),
        "result_featured_image":                   (item.get("result_featured_image") or {}).get("ID"),
        "result_acknowledgements":                 item.get("result_acknowledgements"),
        "result_funding":                          item.get("result_funding"),
        "hide_from_browse_table":                  item.get("hide_from_browse_table"),
        "program":                                 item.get("program"),
        # Result Details
        "cancer_types":                            item.get("cancer_types"),
        "cancer_locations":                        item.get("cancer_locations"),
        "species":                                 item.get("species"),
        "subjects":                                item.get("subjects"),
        # Result Methods
        "subject_inclusion_and_exclusion_criteria": item.get("subject_inclusion_and_exclusion_criteria"),
        "data_acquisition":                        item.get("data_acquisition"),
        "data_analysis":                           item.get("data_analysis"),
        "usage_notes":                             item.get("usage_notes"),
        # Data Access (Current Version)
        "result_downloads":                        item.get("result_downloads"),
        "make_new_version":                        item.get("make_new_version"),
        "version_number":                          item.get("version_number"),
        "date_updated":                            item.get("date_updated"),
        "version_change_log":                      item.get("version_change_log"),
        # Data Access Supplemental
        "result_download_info":                    item.get("result_download_info"),
        "additional_resources":                    item.get("additional_resources"),
        "supporting_data":                         item.get("supporting_data"),
        "related_collections":                     item.get("related_collections"),
        "related_analysis_results":                item.get("related_analysis_results"),
        "collections":                             item.get("collections"),
        "collection_downloads":                    item.get("collection_downloads"),
        "detailed_description":                    item.get("detailed_description"),
        # Citations & Data Usage Policy
        "citations":                               item.get("citations"),
        "publications_related":                    item.get("publications_related"),
        "publications_using":                      item.get("publications_using"),
        # Previous Versions
        "versions":                                item.get("versions"),
    }

def format_download(item: dict) -> dict:
    return {
        **_base(item),
        # Download Info
        "download_title":           item.get("download_title"),
        "download_type":            item.get("download_type"),
        "dcid_type":                item.get("dcid_type"),
        "data_type":                item.get("data_type"),
        "file_type":                item.get("file_type"),
        "heading_example_text":     item.get("heading_example_text"),
        "download_access":          item.get("download_access"),
        "collection_status":        item.get("collection_status"),
        "date_updated":             item.get("date_updated"),
        # Download File Source
        "download_file":            (item.get("download_file") or {}).get("ID"),
        "download_url":             item.get("download_url"),
        "fill_download_specs":      item.get("fill_download_specs"),
        # Download Attributes
        "download_requirements":    item.get("download_requirements"),
        "data_license":             item.get("data_license"),
        "search_url":               item.get("search_url"),
        "display_cdrc_modal_dialog": item.get("display_cdrc_modal_dialog"),
        "description":              item.get("description"),
        # Download Meta
        "cancer_type":              item.get("cancer_type"),
        "cancer_location":          item.get("cancer_location"),
        "species":                  item.get("species"),
        "supporting_data":          item.get("supporting_data"),
        # Download Specs
        "download_size":            item.get("download_size"),
        "download_size_unit":       item.get("download_size_unit"),
        "subjects":                 item.get("subjects"),
        "study_count":              item.get("study_count"),
        "series_count":             item.get("series_count"),
        "image_count":              item.get("image_count"),
        "download_metadata":        (item.get("download_metadata") or {}).get("ID"),
    }

def format_version(item: dict) -> dict:
    return {
        **_base(item),
        # Version Details
        "version_number":          item.get("version_number"),
        "version_date":            item.get("version_date"),
        "related_collection":      item.get("related_collection"),
        "related_analysis_result": item.get("related_analysis_result"),
        # Version Downloads
        "version_text":            item.get("version_text"),
        "version_downloads":       item.get("version_downloads"),
    }

def format_version_download(item: dict) -> dict:
    return format_download(item)

def format_cancer_type(item: dict) -> dict:
    return {**_base(item), "cancer_type_label": item.get("cancer_type_label")}

def format_location(item: dict) -> dict:
    return {**_base(item), "cancer_location_label": item.get("cancer_location_label")}

def format_species(item: dict) -> dict:
    return {**_base(item), "species_label": item.get("species_label")}

def format_data_type(item: dict) -> dict:
    return {**_base(item), "data_type_label": item.get("data_type_label")}

def format_supporting_data(item: dict) -> dict:
    return {**_base(item), "supporting_data_label": item.get("supporting_data_label")}

def format_file_type(item: dict) -> dict:
    return {**_base(item), "file_type_label": item.get("file_type_label")}

def format_license(item: dict) -> dict:
    return {
        **_base(item),
        "license_label": item.get("license_label"),
        "license_url":   item.get("license_url"),
    }

def format_requirement(item: dict) -> dict:
    return {
        **_base(item), 
        "download_requirement_label": item.get("download_requirement_label"),
        "download_requirement_url": item.get("download_requirement_url"),
        "requirement_text": item.get("requirement_text")
    }

def format_program(item: dict) -> dict:
    return {
        **_base(item),
        "program_name":             item.get("program_name"),
        "related_collections":      item.get("related_collections"),
        "related_analysis_results": item.get("related_analysis_results"),
    }


# ----------------------------
# Endpoints
# ----------------------------


@router.get("/media")
async def get_media(search: str = None, mime_type: str = None):
    try:
        p = {}
        if search:    p["search"]    = search
        if mime_type: p["mime_type"] = mime_type
        return [format_media(i) for i in await wp_get_media_paged(params=p)]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/media/{post_id}")
async def get_media_item(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Media')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Media not found")
        return format_media(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/citations")
async def get_citations(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_citation(i) for i in await wp_get_paged(wp_url("Citation"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/citations/{post_id}")
async def get_citation(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Citation')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Citation not found")
        return format_citation(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/collections")
async def get_wp_collections(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_collection(i) for i in await wp_get_paged(wp_url("Collection"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/collections/{post_id}")
async def get_wp_collection(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Collection')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Collection not found")
        return format_collection(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/analysis-results")
async def get_analysis_results(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_analysis_result(i) for i in await wp_get_paged(wp_url("Analysis Result"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/analysis-results/{post_id}")
async def get_analysis_result(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Analysis Result')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Analysis Result not found")
        return format_analysis_result(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/downloads")
async def get_wp_downloads(
    slug: str = None,
    search: str = None,
    status: str = "publish,draft",
    ids: str = None,
    download_type: str = None,
    download_access: str = None,
):
    try:
        results = [format_download(i) for i in await wp_get_paged(wp_url("Download"), _params(slug, search, status, ids))]
        if download_type:
            results = [r for r in results if r.get("download_type") == download_type]
        if download_access:
            results = [r for r in results if r.get("download_access") == download_access]
        return results
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/downloads/{post_id}")
async def get_wp_download(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Download')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Download not found")
        return format_download(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/versions")
async def get_versions(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_version(i) for i in await wp_get_paged(wp_url("Version"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/versions/{post_id}")
async def get_version(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Version')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Version not found")
        return format_version(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/version-downloads")
async def get_version_downloads(
    slug: str = None,
    search: str = None,
    status: str = "publish,draft",
    ids: str = None,
    download_type: str = None,
    download_access: str = None,
):
    try:
        results = [format_version_download(i) for i in await wp_get_paged(wp_url("Version Download"), _params(slug, search, status, ids))]
        if download_type:
            results = [r for r in results if r.get("download_type") == download_type]
        if download_access:
            results = [r for r in results if r.get("download_access") == download_access]
        return results
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/version-downloads/{post_id}")
async def get_version_download(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Version Download')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Version Download not found")
        return format_version_download(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/cancer-types")
async def get_cancer_types(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_cancer_type(i) for i in await wp_get_paged(wp_url("Cancer Type"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/cancer-types/{post_id}")
async def get_cancer_type(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Cancer Type')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Cancer Type not found")
        return format_cancer_type(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/locations")
async def get_locations(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_location(i) for i in await wp_get_paged(wp_url("Location"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/locations/{post_id}")
async def get_location(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Location')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Location not found")
        return format_location(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/species")
async def get_species(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_species(i) for i in await wp_get_paged(wp_url("Species"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/species/{post_id}")
async def get_species_item(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Species')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Species not found")
        return format_species(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/data-types")
async def get_data_types(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_data_type(i) for i in await wp_get_paged(wp_url("Data Type"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/data-types/{post_id}")
async def get_data_type(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Data Type')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Data Type not found")
        return format_data_type(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/supporting-data")
async def get_supporting_data(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_supporting_data(i) for i in await wp_get_paged(wp_url("Supporting Data"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/supporting-data/{post_id}")
async def get_supporting_data_item(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Supporting Data')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Supporting Data not found")
        return format_supporting_data(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/file-types")
async def get_file_types(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_file_type(i) for i in await wp_get_paged(wp_url("File Type"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/file-types/{post_id}")
async def get_file_type(post_id: int):
    try:
        item = await wp_get(f"{wp_url('File Type')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="File Type not found")
        return format_file_type(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/licenses")
async def get_licenses(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_license(i) for i in await wp_get_paged(wp_url("License"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/licenses/{post_id}")
async def get_license(post_id: int):
    try:
        item = await wp_get(f"{wp_url('License')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="License not found")
        return format_license(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/requirements")
async def get_requirements(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_requirement(i) for i in await wp_get_paged(wp_url("Requirement"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/requirements/{post_id}")
async def get_requirement(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Requirement')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Requirement not found")
        return format_requirement(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")


@router.get("/programs")
async def get_programs(slug: str = None, search: str = None, status: str = "publish,draft", ids: str = None):
    try:
        return [format_program(i) for i in await wp_get_paged(wp_url("Program"), _params(slug, search, status, ids))]
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")

@router.get("/programs/{post_id}")
async def get_program(post_id: int):
    try:
        item = await wp_get(f"{wp_url('Program')}/{post_id}")
        if item is None:
            raise HTTPException(status_code=404, detail="Program not found")
        return format_program(item)
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{type(e).__name__}: {e}")
